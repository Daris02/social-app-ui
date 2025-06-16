import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/components/MyTextField.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/providers/auth_provider.dart';
import '../../routes/app_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();

  // Step 1
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  // Step 2
  final _IM = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  // Step 3
  String? _position;
  String? _attribution;
  String? _direction;
  DateTime? _entryDate;
  bool _senator = false;

  final List<String> positions = [
    'SG',
    'IGS',
    'DIRECTEUR',
    'CHEF_DE_SERVICE',
    'CHEF_DE_DIVISION',
    'AGENT_DE_SERVICE',
  ];
  final List<String> attributions = ['Finance', 'RH', 'Technique'];
  final List<String> directions = ['Nord', 'Sud', 'Est', 'Ouest'];

  int _step = 0;

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      if (_step < 2) {
        setState(() => _step++);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() => _step--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _entryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }
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
            position: _position!,
            attribution: _attribution!,
            direction: _direction!,
            entryDate: _entryDate!,
            senator: _senator,
          ),
        );
    if (success) {
      appRouter.go('/login');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Échec d\'inscription')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inscription"),
        leading: _step > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _prevStep,
              )
            : null,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (_step + 1) / 3,
                  minHeight: 4,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Step 1: Infos de base
                      ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const Text(
                            "Informations personnelles",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          MyTextField(
                            labelText: 'Nom',
                            obscureText: false,
                            controller: _firstName,
                            validator: (v) =>
                                v!.isEmpty ? "Champ requis" : null,
                          ),
                          const SizedBox(height: 12),
                          MyTextField(
                            labelText: 'Prénom',
                            obscureText: false,
                            controller: _lastName,
                            validator: (v) =>
                                v!.isEmpty ? "Champ requis" : null,
                          ),
                          const SizedBox(height: 12),
                          MyTextField(
                            controller: _email,
                            labelText: "Email",
                            type: TextInputType.emailAddress,
                            validator: (v) =>
                                v!.contains('@') ? null : "Email invalide",
                            obscureText: null,
                          ),
                          const SizedBox(height: 12),
                          MyTextField(
                            controller: _password,
                            obscureText: true,
                            labelText: "Mot de passe",
                            validator: (v) =>
                                v!.length < 6 ? "6 caractères min." : null,
                          ),
                          const SizedBox(height: 12),
                          MyTextField(
                            controller: _confirmPassword,
                            obscureText: true,
                            labelText: "Confirmer le mot de passe",
                            validator: (v) => v != _password.text
                                ? "Les mots de passe ne correspondent pas"
                                : null,
                          ),
                        ],
                      ),
                      // Step 2: Infos contact
                      ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const Text(
                            "Coordonnées",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          MyTextField(controller: _IM, labelText: "IM"),
                          const SizedBox(height: 12),
                          MyTextField(
                            controller: _phone,
                            labelText: "Téléphone",
                            type: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),
                          MyTextField(
                            controller: _address,
                            labelText: "Adresse",
                          ),
                        ],
                      ),
                      // Step 3: Infos professionnelles
                      ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const Text(
                            "Informations professionnelles",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _position,
                            items: positions
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _position = v),
                            decoration: const InputDecoration(
                              labelText: "Position",
                            ),
                            validator: (v) =>
                                v == null ? "Sélectionnez une position" : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _attribution,
                            items: attributions
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _attribution = v),
                            decoration: const InputDecoration(
                              labelText: "Attribution",
                            ),
                            validator: (v) => v == null
                                ? "Sélectionnez une attribution"
                                : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _direction,
                            items: directions
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _direction = v),
                            decoration: const InputDecoration(
                              labelText: "Direction",
                            ),
                            validator: (v) =>
                                v == null ? "Sélectionnez une direction" : null,
                          ),
                          const SizedBox(height: 12),
                          ListTile(
                            title: Text(
                              _entryDate == null
                                  ? "Date d'entrée au Sénat"
                                  : DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(_entryDate!),
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null)
                                setState(() => _entryDate = picked);
                            },
                          ),
                          CheckboxListTile(
                            value: _senator,
                            onChanged: (v) => setState(() => _senator = v!),
                            title: const Text("Sénateur"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: _step == 0
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.spaceBetween,
                  children: [
                    if (_step > 0)
                      OutlinedButton(
                        onPressed: _prevStep,
                        child: Text(
                          "Précédent",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                      ),
                    if (_step < 2)
                      ElevatedButton(
                        onPressed: _nextStep,
                        child: Text(
                          "Suivant",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                      ),
                    if (_step == 2)
                      ElevatedButton(
                        onPressed: _submit,
                        child: Text(
                          "S'inscrire",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
