import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/components/MyButton.dart';
import 'package:social_app/components/MyTextField.dart';
import 'package:social_app/providers/auth_provider.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/routes/app_router.dart';

// ignore: must_be_immutable
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // logo
                Icon(
                  Icons.person,
                  size: 80,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),

                const SizedBox(height: 25),

                // app name
                Text("S O C I A L", style: TextStyle(fontSize: 20)),

                const SizedBox(height: 50),

                // email
                MyTextField(
                  labelText: 'Email',
                  obscureText: false,
                  controller: _email,
                  validator: (v) => v!.contains('@') ? null : "Email invalide",
                ),

                const SizedBox(height: 10),

                // password
                MyTextField(
                  labelText: 'Password',
                  obscureText: true,
                  controller: _password,
                  validator: (v) => v!.length < 3 ? "3 caractères min." : null,
                ),

                const SizedBox(height: 10),

                // // forgot
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     Text(
                //       'Forgot password ?',
                //       style: TextStyle(
                //         color: Theme.of(context).colorScheme.inversePrimary,
                //       ),
                //     ),
                //   ],
                // ),
                const SizedBox(height: 10),

                // sign in
                MyButton(
                  text: "Se connecter",
                  loading: _loading,
                  onTap: _loading
                      ? null
                      : () async {
                          setState(() => _loading = true);
                          try {
                            if (_formKey.currentState!.validate()) {
                              final success = await ref
                                  .read(authProvider.notifier)
                                  .login(_email.text, _password.text);
                              debugPrint('User : $success');
                              if (success != false) {
                                ref
                                    .read(userProvider.notifier)
                                    .setUser(success);
                                appRouter.go('/');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Échec de connexion'),
                                  ),
                                );
                              }
                            }
                          } finally {
                            setState(() => _loading = false);
                          }
                        },
                ),

                const SizedBox(height: 20),

                // register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account ? ",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => appRouter.push('/register'),
                      child: Text(
                        "Register Here",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
