import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_app/providers/ws_provider.dart';
import 'package:social_app/routes/app_router.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/screens/auth/components/my_button.dart';
import 'package:social_app/screens/auth/components/my_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  late final router;
  final FocusNode _keyboardFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    router = ref.read(appRouterProvider);
  }

  void login() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_formKey.currentState!.validate()) {
        final success = await ref
            .read(userProvider.notifier)
            .login(_email.text, _password.text);
        if (success != false) {
          ref.read(userProvider.notifier).setUser(success);
          final socket = ref.read(webSocketServiceProvider);
          if (!socket.hasConnected) {
            final token = prefs.getString('token');
            socket.connect(token!);
            socket.send('user_connected', {'userId': success.id});
          }
          router.go('/');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Échec de connexion'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  void forgotPassword() {}

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        login();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyboardFocus..requestFocus(),
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: double.infinity),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg-senat.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // logo
                        CircleAvatar(
                          radius: 30,
                          foregroundImage: AssetImage(
                            'assets/logos/logo-senat.png',
                          ),
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
                          validator: (v) =>
                              v!.contains('@') ? null : "Email invalide",
                        ),

                        const SizedBox(height: 10),

                        // password
                        MyTextField(
                          labelText: 'Password',
                          obscureText: true,
                          controller: _password,
                          validator: (v) =>
                              v!.length < 3 ? "3 caractères min." : null,
                        ),

                        const SizedBox(height: 10),

                        // forgot
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () => router.push('/forgot-password'),
                              child: Text(
                                'Mot de passe oublier?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  decorationStyle: TextDecorationStyle.dashed,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // sign in
                        MyButton(
                          text: "Se connecter",
                          loading: _loading,
                          onTap: _loading ? null : login,
                        ),

                        const SizedBox(height: 20),

                        // register link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Vous n'avez pas encore de compte? ",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.inversePrimary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => router.push('/register'),
                              child: Text(
                                "S'inscrire ici",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  decorationStyle: TextDecorationStyle.dashed,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
