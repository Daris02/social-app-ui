import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/constant/helpers.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/providers/ws_provider.dart';
import 'package:social_app/screens/reunion/group_call_screen.dart';
import 'package:social_app/services/group_call_service.dart';
import 'package:social_app/utils/main_drawer.dart';
import 'package:social_app/models/enums/direction.dart';
import 'package:social_app/models/enums/role.dart';

class Reunion extends ConsumerStatefulWidget {
  const Reunion({super.key});

  @override
  ConsumerState createState() => _ReunionState();
}

class _ReunionState extends ConsumerState<Reunion> {
  void startGroupCall() {
    final user = ref.read(userProvider);
    if (user == null) return;
    final dir = user.direction;
    if (dir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Votre direction est inconnue')),
      );
      return;
    }
    _attemptStartGroupCall(dir);
  }

  void _attemptStartGroupCall(Direction dir) {
    final user = ref.read(userProvider);
    if (user == null) return;

    final allowed =
        user.role == Role.MANAGER ||
        user.role == Role.ADMIN ||
        user.direction == dir;
    if (!allowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Accès refusé : vous n\'êtes pas autorisé à rejoindre cette réunion',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final socket = ref.read(webSocketServiceProvider);
    final selfUserId = user.id;
    final roomId = 'group-${dir.name}';

    final roomService = GroupCallRoomService(
      socket: socket,
      roomId: roomId,
      selfUserId: selfUserId,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GroupCallScreen(service: roomService)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Réunion')),
      drawer: isDesktop(context) ? null : MainDrawer(),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: ListTile(
                    title: const Text('Groupes de réunion'),
                    subtitle: const Text(
                      'Sélectionnez une Direction pour lancer ou rejoindre une réunion',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // list of directions
                ...Direction.values.map((d) {
                  final user = ref.watch(userProvider);
                  final canJoin =
                      user != null &&
                      (user.role == Role.MANAGER ||
                          user.role == Role.ADMIN ||
                          user.direction == d);
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.group),
                      title: Text(d.name),
                      subtitle: Text('Groupe ${d.description}'),
                      trailing: canJoin
                          ? const Icon(Icons.video_call)
                          : const Icon(Icons.lock_outline),
                      onTap: canJoin
                          ? () => _attemptStartGroupCall(d)
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Accès refusé : vous ne pouvez pas rejoindre ce groupe',
                                  ),
                                ),
                              );
                            },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
