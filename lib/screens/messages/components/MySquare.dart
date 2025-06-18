import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/screens/messages/components/MyCircle.dart';
import 'package:social_app/screens/messages/message_view.dart';
import 'package:social_app/services/api_service.dart';

class MySquare extends ConsumerWidget {
  final User user;

  const MySquare({required this.user});

  Future<String> _getLastMessage(int partnerId) async {
    final messages = await ApiService.getMessages(partnerId);
    if (messages.isNotEmpty) {
      return messages.first.content ?? 'Aucun message';
    }
    return 'Aucun message récent';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.read(userProvider)!.id;

    return FutureBuilder<String>(
      future: _getLastMessage(user.id),
      builder: (context, snapshot) {
        final lastMessage = snapshot.data ?? 'Chargement...';

        return ListTile(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => MessageView(partner: user),
            ));
          },
          leading: MyCircle(user: user),
          title: Text('${user.firstName} ${user.lastName}'),
          subtitle: Text(
            lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}