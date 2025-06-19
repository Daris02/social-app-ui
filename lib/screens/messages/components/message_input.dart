import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSend;

  const MessageInput({super.key, required this.onSend});

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final controller = TextEditingController();

  void handleSend() {
    final text = controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: "Message...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: handleSend,
          ),
        ],
      ),
    );
  }
}
