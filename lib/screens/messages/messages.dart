import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/constant/helpers.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/providers/ws_provider.dart';
import 'package:social_app/screens/messages/call_screen.dart';
import 'package:social_app/screens/messages/chat_screen.dart';
import 'package:social_app/screens/messages/group_call_screen.dart';
import 'package:social_app/services/call_service.dart';
import 'package:social_app/services/group_call_service.dart';
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
  late VideoCallService _callService;
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

  void fetchContacts() async {
    final data = await UserService.getContacts();
    if (mounted) {
      setState(() {
        _contacts = data;
      });
    }
  }

  void startCall(User partner) async {
    setState(() => _isPreparingCall = true);
    final user = ref.read(userProvider)!;
    final params = VideoCallParams(user.id.toString(), partner.id.toString());
    ref.invalidate(videoCallServiceProvider(params));
    _callService = ref.read(videoCallServiceProvider(params));

    _callService.onCallAccepted = () async {
      if (!mounted) return;
      setState(() {
        _isPreparingCall = false;
        _isInCall = true;
      });
    };

    _callService.onCallRefused = () {
      setState(() {
        _isPreparingCall = false;
        _isInCall = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('L’appel a été refusé')));
    };

    await _callService.connect(true);
    await _callService.startCall();
  }

  void cancelCall() {
    _callService.hangUp(ref);
    setState(() {
      _isPreparingCall = false;
      _isInCall = false;
    });
  }

  void startGroupCall() {
    final socket = ref.read(webSocketServiceProvider);
    final user = ref.read(userProvider)!;
    final selfUserId = user.id;
    final roomId = 'group-${user.direction?.name}';

    final roomService = GroupCallRoomService(
      socket: socket,
      roomId: roomId,
      selfUserId: selfUserId,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GroupCallScreen(service: roomService)),
    );
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
        title: Text(
          _selectedContact != null
              ? 'Messages - ${_selectedContact!.firstName} ${_selectedContact!.lastName}'
              : 'Messages',
        ),
        centerTitle: true,
        actions: [
          if (isDesktop(context) &&
              _selectedContact != null &&
              !_isPreparingCall &&
              !_isInCall)
            IconButton(
              icon: Icon(Icons.video_call),
              onPressed: () => startCall(_selectedContact!),
            ),
        ],
      ),
      drawer: isDesktop(context) ? null : MainDrawer(),
      body: isDesktop(context)
          ? (_isPreparingCall
                ? Column(
                    children: [
                      LinearProgressIndicator(),
                      SizedBox(height: 300),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Appel ${_selectedContact!.firstName} ${_selectedContact!.lastName} ...',
                            ),
                            const SizedBox(height: 12),
                            IconButton(
                              icon: Icon(Icons.call_end, color: Colors.red),
                              iconSize: 75,
                              onPressed: cancelCall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : _isInCall
                ? VideoCallScreen(callService: _callService, isCaller: true)
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
      floatingActionButton: IconButton(
        onPressed: startGroupCall,
        icon: Icon(Icons.group),
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
