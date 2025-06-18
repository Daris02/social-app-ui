import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/models/message.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/providers/ws_provider.dart';
import 'package:social_app/screens/messages/components/message_input.dart';
import 'package:social_app/screens/messages/components/message_list.dart';
import 'package:social_app/services/api_service.dart';

class MessageView extends ConsumerStatefulWidget {
  final User partner;

  const MessageView({required this.partner});

  @override
  ConsumerState<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends ConsumerState<MessageView> {
  late final WebSocketService socket;
  List<Message> messages = [];
  late StreamSubscription<Message> _messageSubscription;

  @override
  void initState() {
    super.initState();
    socket = ref.read(webSocketServiceProvider);
    _messageSubscription = socket.onMessage((msg) {
      if (!mounted) return;
      final currentUserId = ref.read(userProvider)!.id;

      final alreadyExists = messages.any(
        (m) =>
            m.content == msg.content &&
            m.from == msg.from &&
            m.to == msg.to &&
            m.createdAt.difference(msg.createdAt).inSeconds.abs() <
                1, // marge de 1s
      );

      if (!alreadyExists &&
          ((msg.from == widget.partner.id && msg.to == currentUserId) ||
              (msg.from == currentUserId && msg.to == widget.partner.id))) {
        setState(() => messages.add(msg));
        messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      }
    });
    fetchMessages();
  }

  void fetchMessages() async {
    final fetched = await ApiService.getMessages(widget.partner.id);
    setState(() {
      messages = List.from(fetched)
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    });
  }

  void sendMessage(String message) {
    final msg = Message(
      content: message,
      from: ref.read(userProvider)!.id,
      to: widget.partner.id,
      createdAt: DateTime.now(),
    );
    socket.sendMessage(widget.partner.id, msg.content);
  }

  @override
  void dispose() {
    _messageSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.partner.lastName)),
      body: Column(
        children: [
          Expanded(
            child: MessageList(
              messages: messages,
              currentUserId: ref.read(userProvider)!.id,
            ),
          ),
          MessageInput(onSend: sendMessage),
        ],
      ),
    );
  }
}
