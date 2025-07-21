import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/models/enums/position.dart';
import 'package:social_app/screens/auth/components/my_button.dart';
import 'package:social_app/services/auth_service.dart';
import '../../routes/app_router.dart';
import 'package:social_app/models/create_user.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/models/enums/direction.dart';
import 'package:social_app/screens/auth/components/my_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  bool _loading = false;

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
  Position? _position;
  final _attribution = TextEditingController();
  final _service = TextEditingController();
  Direction? _direction;
  DateTime? _entryDate;
  bool _senator = false;

  // Step 4
  final _verificationCode = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

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

  Future<void> _submit(router) async {
    if (!_formKey.currentState!.validate() || _entryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs")),
      );
      return;
    }
    final success = await ref
        .read(userProvider.notifier)
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
            position: _position,
            attribution: _attribution.text,
            service: _service.text,
            direction: _direction!,
            entryDate: _entryDate!,
            senator: _senator,
          ),
        );
    if (success) {
      // router.go('/login');
      setState(() => _step++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscription reussi'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Échec d\'inscription'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Future<bool> _verifyEmail() {

  // }

  void _emailVerified() {}

  @override
  Widget build(BuildContext context) {
    final router = ref.read(appRouterProvider);
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
                            "Informations personnel",
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
                          DropdownButtonFormField<Position>(
                            value: _position,
                            items: Position.values
                                .map(
                                  (position) => DropdownMenuItem(
                                    value: position,
                                    child: Text(position.name),
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
                          MyTextField(
                            controller: _attribution,
                            labelText: "Attribution",
                          ),
                          const SizedBox(height: 12),
                          MyTextField(
                            controller: _service,
                            labelText: "Service",
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<Direction>(
                            value: _direction,
                            items: Direction.values
                                .map(
                                  (direction) => DropdownMenuItem(
                                    value: direction,
                                    child: Text(direction.name),
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
                              if (picked != null) {
                                setState(() => _entryDate = picked);
                              }
                            },
                          ),
                          CheckboxListTile(
                            value: _senator,
                            onChanged: (v) => setState(() => _senator = v!),
                            title: const Text("secretaire particullier"),
                          ),
                        ],
                      ),
                      // Step 4: Verifcation par email
                      ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          const Text(
                            "Email verification code",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          MyTextField(
                            labelText: 'Code de verfication',
                            obscureText: false,
                            controller: _verificationCode,
                            validator: (v) => (v!.isEmpty && (v.length < 6))
                                ? "Champ requis et 6 caractères min."
                                : null,
                          ),
                          const SizedBox(height: 16),
                          MyButton(
                            text: "Verifier",
                            loading: _loading,
                            onTap: _loading
                                ? null
                                : () async {
                                    setState(() => _loading = true);
                                    try {
                                      final isValide =
                                          await AuthService.verifyEmailWithCode(
                                            _email.text,
                                            _verificationCode.text,
                                          );
                                      if (isValide) {
                                        router.go('/login');
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Échec de verification du code',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } finally {
                                      setState(() => _loading = false);
                                    }
                                  },
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () async {
                              await AuthService.resendCode(_email.text);
                            },
                            child: Text(
                              "Renvoyer le code de verification",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
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
                    if (_step > 0 && _step < 3)
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
                        onPressed: () => _submit(router),
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
