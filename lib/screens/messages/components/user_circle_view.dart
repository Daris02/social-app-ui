import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/providers/ws_provider.dart';
import 'package:social_app/screens/messages/chat_screen.dart';

class UserCircleView extends ConsumerWidget {
  final User user;

  const UserCircleView({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(webSocketServiceProvider).isConnected(user.id);
    final colorSchema = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(partner: user),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 65,
              width: 65,
              child: (user.photo == null || user.photo == '')
                  ? Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isOnline ? Colors.green : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.account_circle_outlined,
                              size: 45,
                              color: colorSchema.inversePrimary,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorSchema.inversePrimary,
                            border: Border.all(
                              color: isOnline ? Colors.green : Colors.grey,
                              width: 2,
                            ),
                            image: DecorationImage(
                              image: NetworkImage(user.photo!),
                              fit: BoxFit.cover,
                              onError: (error, stackTrace) {
                                if (kDebugMode) {
                                  debugPrint(
                                    'Error loading user photo: $error',
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
