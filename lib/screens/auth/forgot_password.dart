import 'package:flutter/material.dart';
import 'package:social_app/screens/auth/components/my_button.dart';
import 'package:social_app/screens/auth/components/my_text_field.dart';
import 'package:social_app/services/auth_service.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _step = 0;
  bool _loading = false;

  // Step 1 : Email
  final _email = TextEditingController();

  // Step 2 : Code de vérification + Nouveau mot de passe
  final _code = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      setState(() => _step++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
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
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final success = await AuthService.resetPassword(
        _email.text,
        _code.text,
        _newPassword.text,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Mot de passe réinitialisé"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Échec de réinitialisation"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Réinitialiser le mot de passe"),
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
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (_step + 1) / 2,
                  minHeight: 4,
                  color: colorScheme.inversePrimary,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // ÉTAPE 1 : Entrer Email
                      ListView(
                        children: [
                          const Text(
                            "Entrez votre email pour recevoir un code",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          MyTextField(
                            labelText: 'Email',
                            controller: _email,
                            type: TextInputType.emailAddress,
                            validator: (v) =>
                                v!.contains('@') ? null : "Email invalide",
                          ),
                          const SizedBox(height: 20),
                          MyButton(
                            text: "Envoyer le code",
                            onTap: () async {
                              final success = await AuthService.forgotPassword(
                                _email.text,
                              );
                              if (success) {
                                _nextStep();
                              } else {
                                _email.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Email non envoyer"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      // ÉTAPE 2 : Vérifier le code + Nouveau mot de passe
                      ListView(
                        children: [
                          const Text(
                            "Code de vérification & nouveau mot de passe",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          MyTextField(
                            labelText: 'Code',
                            controller: _code,
                            validator: (v) =>
                                v!.isEmpty ? "Champ requis" : null,
                          ),
                          const SizedBox(height: 12),
                          MyTextField(
                            labelText: 'Nouveau mot de passe',
                            controller: _newPassword,
                            obscureText: true,
                            validator: (v) =>
                                v!.length < 6 ? "6 caractères minimum" : null,
                          ),
                          const SizedBox(height: 12),
                          MyTextField(
                            labelText: 'Confirmer le mot de passe',
                            controller: _confirmPassword,
                            obscureText: true,
                            validator: (v) => v != _newPassword.text
                                ? "Les mots de passe ne correspondent pas"
                                : null,
                          ),
                          const SizedBox(height: 20),
                          MyButton(
                            text: "Réinitialiser",
                            loading: _loading,
                            onTap: _loading ? null : _submit,
                          ),
                        ],
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
