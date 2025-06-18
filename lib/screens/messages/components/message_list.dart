import 'package:flutter/material.dart';
import 'package:social_app/models/message.dart';

class MessageList extends StatelessWidget {
  final List<Message> messages;
  final int currentUserId;

  const MessageList({required this.messages, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      padding: EdgeInsets.all(8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        final isMe = message.from == currentUserId;
        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 2),
            padding: EdgeInsets.all(10),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(message.content, style: TextStyle(color: isMe ? Colors.white : Colors.black)),
          ),
        );
      },
    );
  }
}
