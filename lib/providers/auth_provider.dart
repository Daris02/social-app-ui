import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_app/providers/ws_provider.dart';
import 'package:social_app/services/auth_service.dart';
import '../models/user.dart';

final authProvider = StateNotifierProvider<AuthController, User?>(
  (ref) => AuthController(ref),
);

final authInitProvider = FutureProvider<void>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString('user');

  if (userJson != null) {
    final user = User.fromJson(jsonDecode(userJson));
    // ref.read(authProvider.notifier).state = user;
    ref.read(webSocketServiceProvider).connect(user.token);
    ref.read(webSocketServiceProvider).send('user_connected', {
      'userId': user.id,
    });
  }
});

class AuthController extends StateNotifier<User?> {
  final Ref ref;

  AuthController(this.ref) : super(null);

  Future<dynamic> login(String email, String password) async {
    try {
      final user = await AuthService.login(email, password);
      if (user == null || user == 'Fail login') return false;

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('user', jsonEncode(user.toJson()));
      state = user;
      ref.read(webSocketServiceProvider).connect(user.token);
      ref.read(webSocketServiceProvider).send('user_connected', {
        'userId': user.id,
      });
      return user;
    } catch (err) {
      if (kDebugMode) {
        print('Error during login: $err');
      }
      return false;
    }
  }

  Future<bool> register(CreateUser newUser) async {
    try {
      final data = await AuthService.register(newUser);
      if (data == null) {
        return false;
      }
      if (data == 'Fail registration') {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      ref.read(webSocketServiceProvider).send('user_disconnected', {
        'userId': state?.id,
      });
      ref.read(webSocketServiceProvider).disconnect();
      state = null;
      return true;
    } catch (err) {
      return false;
    }
  }
}
