import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/services/auth_service.dart';
import '../routes/app_router.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState createState() => _SettingState();
}

class _SettingState extends ConsumerState<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final success = await ref.read(authProvider.notifier).logout();
              if (success) appRouter.go('/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(child: Text('Paramtres')),
    );
  }
}
