import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_app/models/create_user.dart';
import 'package:social_app/providers/ws_provider.dart';
import 'package:social_app/services/auth_service.dart';
import '../models/user.dart';

final userProvider = StateNotifierProvider<UserController, User?>((ref) {
  return UserController(ref);
});

final userInitProvider = FutureProvider<void>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString('user');

  if (userJson != null) {
    final user = User.fromJson(jsonDecode(userJson));
    ref.read(userProvider.notifier).state = user;
    ref.read(webSocketServiceProvider).connect(user.token);
    ref.read(webSocketServiceProvider).send('user_connected', {
      'userId': user.id,
    });
  }
});

class UserController extends StateNotifier<User?> {
  final Ref ref;
  static const _userKey = 'current_user';

  UserController(this.ref) : super(null) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      final user = User.fromJson(jsonDecode(userData));
      state = user;

      ref.read(webSocketServiceProvider).connect(user.token);
      ref.read(webSocketServiceProvider).send('user_connected', {
        'userId': user.id,
      });
    }
  }

  Future<void> setUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    state = user;

    ref.read(webSocketServiceProvider).connect(user.token);
    ref.read(webSocketServiceProvider).send('user_connected', {
      'userId': user.id,
    });
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    ref.read(webSocketServiceProvider).send('user_disconnected', {
      'userId': state?.id,
    });
    ref.read(webSocketServiceProvider).disconnect();
    state = null;
  }

  Future<dynamic> login(String email, String password) async {
    try {
      final user = await AuthService.login(email, password);
      if (user == null || user == 'Fail login') return false;

      await setUser(user);
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
      final res = await AuthService.register(newUser);
      return res;
    } catch (_) {
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      await clearUser();
      return true;
    } catch (err) {
      return false;
    }
  }
}
