import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  // final post
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notifications'), actions: []),
      body: ListView(
        children: [
          // MySquare(),
          // MySquare(),
          // MySquare(),
          // MySquare(),
          // MySquare(),
          // MySquare(),
        ],
      ),
    );
  }
}
