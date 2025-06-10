import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/services/auth_service.dart';
import '../routes/app_router.dart';

class RegisterScreen extends ConsumerWidget {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text("Inscription")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _username, decoration: InputDecoration(labelText: "Nom d'utilisateur")),
            TextField(controller: _email, decoration: InputDecoration(labelText: "Email d'utilisateur")),
            TextField(controller: _password, obscureText: true, decoration: InputDecoration(labelText: "Mot de passe")),
            ElevatedButton(
              onPressed: () async {
                final success = await ref.read(authProvider.notifier).register(_username.text, _email.text, _password.text);
                if (success) {
                  appRouter.go('/');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec d\'inscription')));
                }
              },
              child: Text("S'inscrire"),
            ),
          ],
        ),
      ),
    );
  }
}
