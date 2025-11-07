import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/theme/theme_provider.dart';

class EditAccountScreen extends ConsumerStatefulWidget {
  final User user;
  const EditAccountScreen({super.key, required this.user});

  @override
  ConsumerState createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends ConsumerState<EditAccountScreen> {
  late User user;
  late ColorScheme colorScheme;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    colorScheme = ref.read(themeProvider).colorScheme;
  }

  final bool _showPassword = false;

  Future<void> _showEditDialog(
    String title,
    String currentValue,
    String field,
  ) async {
    final controller = TextEditingController(text: currentValue);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(color: colorScheme.inversePrimary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(
              'Enregistrer',
              style: TextStyle(color: colorScheme.inversePrimary),
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        debugPrint('============================');
        debugPrint('Resultat: $result');
        debugPrint('============================');
      });
      // TODO: Appeler l'API pour mettre à jour le champ
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$title mis à jour')));
    }
  }

  Future<void> _showPasswordChangeDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Changer le mot de passe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: !_showPassword,
              decoration: const InputDecoration(
                labelText: 'Mot de passe actuel',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              obscureText: !_showPassword,
              decoration: const InputDecoration(
                labelText: 'Nouveau mot de passe',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: !_showPassword,
              decoration: const InputDecoration(
                labelText: 'Confirmer le mot de passe',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(color: colorScheme.inversePrimary),
            ),
          ),
          TextButton(
            onPressed: () {
              if (newPasswordController.text.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Le mot de passe doit contenir au moins 8 caractères',
                    ),
                  ),
                );
                return;
              }
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Les mots de passe ne correspondent pas'),
                  ),
                );
                return;
              }
              // TODO: Appeler l'API pour changer le mot de passe
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Mot de passe mis à jour')),
              );
            },
            child: Text(
              'Enregistrer',
              style: TextStyle(color: colorScheme.inversePrimary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorSchema = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Photo de profil
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(user.photo!)
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          backgroundColor: colorSchema.primaryContainer,
                          radius: 18,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, size: 18),
                            onPressed: () {
                              // TODO: Implémenter le changement de photo
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Informations personnelles
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Informations personnelles'),
                        titleTextStyle: Theme.of(context).textTheme.titleMedium,
                      ),
                      ListTile(
                        title: const Text('IM'),
                        subtitle: Text(user.IM),
                        trailing: const Icon(Icons.edit),
                        onTap: () => _showEditDialog('IM', user.IM, 'IM'),
                      ),
                      ListTile(
                        title: const Text('Nom'),
                        subtitle: Text(user.lastName),
                        trailing: const Icon(Icons.edit),
                        onTap: () =>
                            _showEditDialog('Nom', user.lastName, 'lastName'),
                      ),
                      ListTile(
                        title: const Text('Prénom'),
                        subtitle: Text(user.firstName),
                        trailing: const Icon(Icons.edit),
                        onTap: () => _showEditDialog(
                          'Prénom',
                          user.firstName,
                          'firstName',
                        ),
                      ),
                      ListTile(
                        title: const Text('Email'),
                        subtitle: Text(user.email),
                        trailing: const Icon(Icons.edit),
                        onTap: () =>
                            _showEditDialog('Email', user.email, 'email'),
                      ),
                      ListTile(
                        title: const Text('Téléphone'),
                        subtitle: Text(user.phone),
                        trailing: const Icon(Icons.edit),
                        onTap: () =>
                            _showEditDialog('Téléphone', user.phone, 'phone'),
                      ),
                      ListTile(
                        title: const Text('Adresse'),
                        subtitle: Text(user.address),
                        trailing: const Icon(Icons.edit),
                        onTap: () =>
                            _showEditDialog('Adresse', user.address, 'address'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Informations professionnelles
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Informations professionnelles'),
                        titleTextStyle: Theme.of(context).textTheme.titleMedium,
                      ),
                      ListTile(
                        title: const Text('Position'),
                        subtitle: Text(user.position.name),
                      ),
                      ListTile(
                        title: const Text('Attribution'),
                        subtitle: Text(user.attribution),
                      ),
                      if (user.service != null)
                        ListTile(
                          title: const Text('Service'),
                          subtitle: Text(user.service!),
                        ),
                      if (user.direction != null)
                        ListTile(
                          title: const Text('Direction'),
                          subtitle: Text(user.direction!.name),
                        ),
                      ListTile(
                        title: const Text('Rôle'),
                        subtitle: Text(user.role.name),
                      ),
                      ListTile(
                        title: const Text('Date d\'entrée'),
                        subtitle: Text(user.entryDate.toString().split(' ')[0]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Sécurité
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Sécurité'),
                        titleTextStyle: Theme.of(context).textTheme.titleMedium,
                      ),
                      ListTile(
                        title: const Text('Changer le mot de passe'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: _showPasswordChangeDialog,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
