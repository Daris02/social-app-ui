import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/providers/ws_provider.dart';
import 'package:social_app/services/user_service.dart';
import 'package:social_app/screens/messages/components/user_circle_view.dart';
import 'package:social_app/screens/messages/components/last_message_view.dart';

class MessageScreen extends ConsumerStatefulWidget {
  const MessageScreen({super.key});
  @override
  ConsumerState<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends ConsumerState<MessageScreen> {
  late List<User> _contacts = [];
  late StreamSubscription<Set<int>> _userStatusSub;

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

  @override
  void dispose() {
    _userStatusSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Messages')),
      body: Column(
        children: [
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                return UserCircleView(user: _contacts[index]);
              },
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child:
                kIsWeb ||
                    Platform.isWindows ||
                    Platform.isLinux ||
                    Platform.isMacOS
                ? _buildListView()
                : RefreshIndicator(
                    onRefresh: () async {
                      fetchContacts();
                      setState(() {});
                    },
                    child: _buildListView(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        return LastMessageView(user: _contacts[index]);
      },
    );
  }
}
