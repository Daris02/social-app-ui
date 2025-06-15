import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/providers/auth_provider.dart';
import 'package:social_app/providers/user_provider.dart';
import '../routes/app_router.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState createState() => _SettingState();
}

class _SettingState extends ConsumerState<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final success = await ref.read(authProvider.notifier).logout();
              ref.read(userProvider.notifier).clearUser();
              if (success) appRouter.go('/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: ListView(children: [Text('User data : ${user?.email}')]),
      ),
    );
  }
}
