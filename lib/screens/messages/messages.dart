import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/constant/helpers.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/providers/ws_provider.dart';
import 'package:social_app/screens/messages/call_screen.dart';
import 'package:social_app/screens/messages/chat_screen.dart';
import 'package:social_app/services/call_service.dart';
import 'package:social_app/services/user_service.dart';
import 'package:social_app/screens/messages/components/last_message_item.dart';
import 'package:social_app/utils/main_drawer.dart';

class MessageScreen extends ConsumerStatefulWidget {
  const MessageScreen({super.key});
  @override
  ConsumerState<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends ConsumerState<MessageScreen> {
  late List<User> _contacts = [];
  User? _selectedContact;
  bool _isPreparingCall = false;
  bool _isInCall = false;
  late VideoCallService? _callService;
  late StreamSubscription<Set<int>> _userStatusSub;
  final FocusNode _keyboardFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    fetchContacts();

    _userStatusSub = ref
        .read(webSocketServiceProvider)
        .connectedUsersStream
        .listen((_) {
          if (mounted) {
            setState(() {});
          }
        });
  }

  void startCall(User partner) async {
    setState(() => _isPreparingCall = true);
    final user = ref.read(userProvider)!;
    final params = VideoCallParams(user.id.toString(), partner.id.toString());
    ref.invalidate(videoCallServiceProvider(params));
    _callService = ref.read(videoCallServiceProvider(params));

    _callService?.onCallAccepted = () async {
      if (!mounted) return;
      setState(() {
        _isPreparingCall = false;
        _isInCall = true;
      });
    };

    _callService?.onCallRefused = () {
      setState(() {
        _isPreparingCall = false;
        _isInCall = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('L’appel a été refusé')));
    };

    await _callService?.connect(true);
    await _callService?.startCall();
  }

  void cancelCall() {
    _callService?.refuseCall();
    setState(() {
      _isPreparingCall = false;
      _isInCall = false;
    });
  }

  void fetchContacts() async {
    final data = await UserService.getContacts();
    if (mounted) {
      setState(() {
        _contacts = data;
      });
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.f5) {
        fetchContacts();
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _userStatusSub.cancel();
    _keyboardFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isDesktop(context) ? Text(
          _selectedContact != null
              ? '${_selectedContact!.firstName} ${_selectedContact!.lastName}'
              : 'Messages',
        ) : const Text('Messages'),
        actions: [
          if (isDesktop(context) &&
              _selectedContact != null &&
              !_isPreparingCall &&
              !_isInCall)
            IconButton(
              icon: Icon(Icons.video_call),
              onPressed: () => startCall(_selectedContact!),
            ),
          if (isDesktop(context) && (_isPreparingCall || _isInCall))
            IconButton(
              icon: Icon(Icons.call_end, color: Colors.red),
              onPressed: cancelCall,
            ),
        ],
      ),
      drawer: isDesktop(context) ? null : MainDrawer(),
      body: isDesktop(context)
          ? (_isPreparingCall
                ? Center(child: LinearProgressIndicator())
                : _isInCall
                ? VideoCallScreen(callService: _callService!, isCaller: true)
                : Row(
                    children: [
                      Expanded(flex: 2, child: _buildListView()),
                      Expanded(
                        flex: 3,
                        child: _selectedContact != null
                            ? ChatScreen(
                                key: ValueKey(_selectedContact!.id),
                                partner: _selectedContact!,
                              )
                            : Center(child: Text('Sélectionnez un contact')),
                      ),
                    ],
                  ))
          : RefreshIndicator(
              onRefresh: () async {
                fetchContacts();
                setState(() {});
              },
              child: _buildListView(),
            ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final user = _contacts[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: LastMessageView(
            user: user,
            isSelected: _selectedContact?.id == user.id,
            onTap: () {
              if (isDesktop(context)) {
                setState(() {
                  _selectedContact = user;
                });
              } else {
                setState(() {
                  _selectedContact = null;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatScreen(partner: user)),
                );
              }
            },
          ),
        );
      },
    );
  }
}
