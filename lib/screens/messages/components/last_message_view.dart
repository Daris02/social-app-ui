import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/services/message_service.dart';
import 'package:social_app/screens/messages/message_view.dart';
import 'package:social_app/screens/messages/components/user_circle_view.dart';

class LastMessageView extends ConsumerWidget {
  final User user;

  const LastMessageView({super.key, required this.user});

  Future<String> _getLastMessage(int partnerId) async {
    final messages = await MessageService.getMessages(partnerId);
    if (messages.isNotEmpty) {
      return messages.first.content;
    }
    return 'Aucun message récent';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String>(
      future: _getLastMessage(user.id),
      builder: (context, snapshot) {
        final lastMessage = snapshot.data ?? 'Chargement...';

        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MessageView(partner: user)),
            );
          },
          leading: Container(
            height: 70,
            width: 100,
            child: UserCircleView(user: user),
          ),
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
