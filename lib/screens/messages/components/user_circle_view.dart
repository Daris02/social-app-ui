import 'package:flutter/foundation.dart';
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
    final colorSchema = Theme.of(context).colorScheme;
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
            SizedBox(
              height: 65,
              width: 65,
              child: (user.photo == null || user.photo == '')
                  ? Stack(
                      children: [
                        Icon(
                          Icons.account_circle_outlined,
                          size: 60,
                          color: colorSchema.inversePrimary,
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
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
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
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
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
