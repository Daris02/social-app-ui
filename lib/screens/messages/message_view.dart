import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/models/message.dart';
import 'package:social_app/providers/ws_provider.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/services/message_service.dart';
import 'package:social_app/services/call_service.dart';
import 'package:social_app/screens/messages/call_screen.dart';
import 'package:social_app/screens/messages/components/message_list.dart';
import 'package:social_app/screens/messages/components/message_input.dart';
import 'package:social_app/utils/notification_call.dart';

class MessageView extends ConsumerStatefulWidget {
  final User partner;

  const MessageView({super.key, required this.partner});

  @override
  ConsumerState<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends ConsumerState<MessageView> {
  late final WebSocketService socket;
  late final User partner;
  late final String roomId;
  List<Message> messages = [];
  bool _isPreparingCall = false;
  late StreamSubscription<Message> _messageSubscription;

  @override
  void initState() {
    super.initState();
    partner = widget.partner;
    socket = ref.read(webSocketServiceProvider);

    _messageSubscription = socket.onMessage((msg) {
      final currentUserId = ref.read(userProvider)!.id;
      if (msg.from == currentUserId) return;
      if (messages.any((m) => m.id == msg.id)) return;
      setState(() => messages.add(msg));
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    });

    fetchMessages();
  }

  void fetchMessages() async {
    final fetched = await MessageService.getMessages(partner.id);
    setState(() {
      messages = List.from(fetched)
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    });
  }

  void sendMessage(String message) {
    final user = ref.read(userProvider)!;
    final msg = Message(
      content: message,
      from: user.id,
      to: partner.id,
      createdAt: DateTime.now(),
    );
    setState(() {
      messages.add(msg);
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    });
    ref.read(webSocketServiceProvider).sendMessage(partner.id, msg.content);
  }

  @override
  void dispose() {
    _messageSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(partner.lastName),
        actions: [
          IconButton(
            onPressed: _isPreparingCall
                ? null
                : () async {
                    setState(() => _isPreparingCall = true);
                    final params = VideoCallParams(
                      user.id.toString(),
                      partner.id.toString(),
                    );
                    ref.invalidate(videoCallServiceProvider(params));
                    final callService = ref.read(
                      videoCallServiceProvider(params),
                    );

                    callService.onCallAccepted = () async {
                      if (!mounted) return;
                      setState(() => _isPreparingCall = false);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoCallScreen(
                            callService: callService,
                            isCaller: true,
                          ),
                        ),
                      );
                    };

                    callService.onCallRefused = () {
                      setState(() => _isPreparingCall = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('L’appel a été refusé')),
                      );
                    };

                    await callService.connect(true);
                    await callService.startCall();
                  },

            icon: Icon(Icons.video_call),
          ),
        ],
      ),
      body: _isPreparingCall
          ? LinearProgressIndicator()
          : Column(
              children: [
                Expanded(
                  child: MessageList(
                    messages: messages,
                    currentUserId: user.id,
                  ),
                ),
                MessageInput(onSend: sendMessage),
              ],
            ),
    );
  }
}
