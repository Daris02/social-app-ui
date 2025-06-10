import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/services/auth_service.dart';
import '../routes/app_router.dart';

class RegisterScreen extends ConsumerWidget {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _IM = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _position = TextEditingController();
  final _attribution = TextEditingController();
  final _direction = TextEditingController();
  final _entryDate = TextEditingController();
  // final _senator = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text("Inscription")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _firstName,
              decoration: InputDecoration(labelText: "Nom"),
            ),
            TextField(
              controller: _lastName,
              decoration: InputDecoration(labelText: "Prenom"),
            ),
            TextField(
              controller: _email,
              decoration: InputDecoration(labelText: "Email d'utilisateur"),
            ),
            TextField(
              controller: _IM,
              decoration: InputDecoration(labelText: "IM"),
            ),
            TextField(
              controller: _phone,
              decoration: InputDecoration(labelText: "Telephone"),
            ),
            TextField(
              controller: _address,
              decoration: InputDecoration(labelText: "Addresse"),
            ),
            TextField(
              controller: _position,
              decoration: InputDecoration(labelText: "Position"),
            ),
            TextField(
              controller: _attribution,
              decoration: InputDecoration(labelText: "Attribution"),
            ),
            TextField(
              controller: _direction,
              decoration: InputDecoration(labelText: "Direction"),
            ),
            TextField(
              controller: _entryDate,
              decoration: InputDecoration(labelText: "Date d'enntrer au Sénat"),
            ),
            // TextField(controller: _senator, decoration: InputDecoration(labelText: "Senateur")),
            // Checkbox(),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(labelText: "Mot de passe"),
            ),
            TextField(
              controller: _confirmPassword,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Confirmer votre mot de passe",
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await ref
                    .read(authProvider.notifier)
                    .register(
                      CreateUser(
                        firstName: _firstName.text,
                        lastName: _lastName.text,
                        email: _email.text,
                        IM: _IM.text,
                        password: _password.text,
                        confirmPassword: _confirmPassword.text,
                        phone: _phone.text,
                        address: _address.text,
                        position: _position.text,
                        attribution: _attribution.text,
                        direction: _direction.text,
                        entryDate: DateTime.parse(_entryDate.text),
                        senator: false,
                      )
                    );
                if (success) {
                  appRouter.go('/');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Échec d\'inscription')),
                  );
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
