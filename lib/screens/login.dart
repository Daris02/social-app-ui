import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_app/routes/app_router.dart';
import 'package:social_app/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  final _username = TextEditingController();
  final _password = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isConnected = false;
    SharedPreferences.getInstance().then((prefs) {
      final token = prefs.getString('token');
      if (token != null) isConnected = true;
      if (isConnected) appRouter.go('/');
    });

    return Scaffold(
      appBar: AppBar(title: Text("Connexion")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _username,
              decoration: InputDecoration(labelText: "Nom d'utilisateur"),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(labelText: "Mot de passe"),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await ref
                    .read(authProvider.notifier)
                    .login(_username.text, _password.text);

                if (success) {
                  ref.read(authProvider);
                  appRouter.go('/');
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Échec de connexion')));
                }
              },
              child: Text("Se connecter"),
            ),
            TextButton(
              onPressed: () => appRouter.push('/register'),
              child: Text("Créer un compte"),
            ),
          ],
        ),
      ),
    );
  }
}
