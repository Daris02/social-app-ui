import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/constant/helpers.dart';
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
    final router = ref.read(appRouterProvider);
    return Scaffold(
      appBar: AppBar(title: Text("Paramètre")),
      drawer: isDesktop(context)
          ? null
          : myDrawer(context, router, userProvider),
      body: Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 20,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Icon(Icons.person),
                Text('${user?.firstName} ${user?.lastName}'),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [Icon(Icons.email), Text('${user?.email}')],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [Icon(Icons.phone), Text('${user?.phone}')],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [Icon(Icons.info), Text('Info plus ...')],
            ),

            GestureDetector(
              onTap: () async {
                final success = await ref.read(userProvider.notifier).logout();
                if (success) router.go('/login');
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [Icon(Icons.exit_to_app), Text('Se déconnecter')],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
