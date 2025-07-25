import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      if (_formKey.currentState!.validate()) {
        final success = await ref
            .read(userProvider.notifier)
            .login(_email.text, _password.text);
        if (success != false) {
          ref.read(userProvider.notifier).setUser(success);
          final socket = ref.read(webSocketServiceProvider);
          if (!socket.hasConnected) {
            socket.connect(success.token);
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
            constraints: const BoxConstraints(maxWidth: 400),
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
                    onTap: _loading ? null : login,
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
                        onTap: () => router.push('/register'),
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
      ),
    );
  }
}
