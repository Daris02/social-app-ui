import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/constant/helpers.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/providers/ws_provider.dart';
import 'package:social_app/screens/reunion/group_call_screen.dart';
import 'package:social_app/services/group_call_service.dart';
import 'package:social_app/utils/main_drawer.dart';

class Reunion extends ConsumerStatefulWidget {
  const Reunion({ super.key });

  @override
  ConsumerState createState() => _ReunionState();
}

class _ReunionState extends ConsumerState<Reunion> {

  void startGroupCall() {
    final socket = ref.read(webSocketServiceProvider);
    final user = ref.read(userProvider)!;
    final selfUserId = user.id;
    final roomId = 'group-${user.direction?.name}';

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
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('Reunion'),
      ),
      drawer: isDesktop(context) ? null : MainDrawer(),
      body: Center(
        child: Text(''),
      ),
      floatingActionButton: FloatingActionButton(
              onPressed: startGroupCall,
              child: Icon(Icons.group, color: colorScheme.inversePrimary),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
    );
  }
}