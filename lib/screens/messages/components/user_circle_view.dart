import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/providers/ws_provider.dart';
import 'package:social_app/screens/messages/message_view.dart';

class UserCircleView extends ConsumerWidget {
  final User user;

  const UserCircleView({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(webSocketServiceProvider).isConnected(user.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MessageView(partner: user)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 65,
              width: 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade300,
                image: user.photo != null
                    ? DecorationImage(
                        image: NetworkImage(user.photo!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: user.photo == null
                  ? Center(
                      child: Text(
                        user.lastName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
            if (isOnline)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
