import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_app/models/create_user.dart';
import 'package:social_app/providers/ws_provider.dart';
import 'package:social_app/services/auth_service.dart';
import 'package:social_app/services/user_service.dart';
import '../models/user.dart';

final userProvider = StateNotifierProvider<UserController, User?>((ref) {
  return UserController(ref);
});

final userInitProvider = FutureProvider<void>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final userJson = prefs.getString('current_user');
  final token = prefs.getString('token');
  if (userJson != null && token != null) {
    final validToken = await tokenIsValid(token);
    if (!validToken) {
      await prefs.remove('current_user');
      await prefs.remove('token');
      return;
    }
    final user = User.fromJson(jsonDecode(userJson));
    await ref.read(userProvider.notifier).setUser(user);
    final socket = ref.read(webSocketServiceProvider);
    bool connected = false;
    if (!socket.hasConnected) {
      socket.connect(token);
      socket.send('user_connected', {'userId': user.id});
      connected = true;
    }
    if (!connected) {
      await ref.read(userProvider.notifier).clearUser();
    }
  } else {
    await ref.read(userProvider.notifier).clearUser();
  }
});

tokenIsValid(String token) async {
  final statusCode = await AuthService.whoami(token);
  if (statusCode == 200) {
    return true;
  }
  return false;
}

class UserController extends StateNotifier<User?> {
  final Ref ref;
  static const _userKey = 'current_user';

  UserController(this.ref) : super(null);

  Future<User?> getUserById(int id) async {
    try {
      final user = await UserService.getUserById(id);
      if (user == null) {
        debugPrint('User not found');
        return null;
      }
      return user;
    } catch (err) {
      if (kDebugMode) {
        print('Error getting user: $err');
      }
      return null;
    }
  }

  Future<void> setUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    state = user;
  }

  Future<void> clearUser() async {
    await ref.read(webSocketServiceProvider).disconnect();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    await prefs.remove('token');
    await prefs.reload();
    state = null;
  }

  Future<dynamic> login(String email, String password) async {
    try {
      final user = await AuthService.login(email, password);
      if (user == false) return false;
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
      if (res == 'user_created') return true;
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      ref.read(webSocketServiceProvider).disconnect();
      await clearUser();
      return true;
    } catch (err) {
      return false;
    }
  }
}
