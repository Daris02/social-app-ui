import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/main.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/screens/messages/call_screen.dart';
import 'package:social_app/services/call_service.dart';

class InAppIncomingCallScreen extends ConsumerWidget {
  final String peerName;
  final String peerId;

  const InAppIncomingCallScreen({
    super.key,
    required this.peerName,
    required this.peerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorTheme = Theme.of(context).colorScheme;
    final user = ref.read(userProvider);
    final params = VideoCallParams(user!.id.toString(), peerId);
    final callService = ref.read(videoCallServiceProvider(params));
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 500,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            surfaceTintColor: colorTheme.inversePrimary,
            color: colorTheme.surface,
            margin: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.call, size: 64, color: Colors.teal),
                  const SizedBox(height: 16),
                  Text(
                    '$peerName vous appelle',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.call_end),
                        label: const Text('Refuser'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await callService.connect(false);
                          await callService.readyFuture;
                          await callService.refuseCall();
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.call),
                        label: const Text('Accepter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await callService.connect(false);
                          await callService.readyFuture;
                          await callService.acceptCall();

                          navigatorKey.currentState?.push(
                            MaterialPageRoute(
                              builder: (_) => VideoCallScreen(
                                callService: callService,
                                isCaller: false,
                                isDesktopApp: true,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
