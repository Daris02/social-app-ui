import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/services/message_service.dart';
import 'package:social_app/screens/messages/components/user_circle_view.dart';

class LastMessageView extends ConsumerWidget {
  final User user;
  final bool isSelected;
  final VoidCallback onTap;

  const LastMessageView({
    super.key,
    required this.user,
    required this.onTap,
    this.isSelected = false,
  });

  Future<String> _getLastMessage() async {
    final messages = await MessageService.getMessages(user.id);
    if (messages.isNotEmpty) {
      return messages.first.content ?? 'Aucun message';
    }
    return 'Aucun message récent';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<String>(
      future: _getLastMessage(),
      builder: (context, snapshot) {
        final lastMessage = snapshot.data ?? 'Chargement...';

        return ListTile(
          selected: isSelected,
          onTap: onTap,
          leading: SizedBox(
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
