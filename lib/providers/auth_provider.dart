import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

final authProvider = StateNotifierProvider<AuthController, User?>(
  (ref) => AuthController(),
);

class AuthController extends StateNotifier<User?> {
  AuthController() : super(null);

  Future<dynamic> login(String email, String password) async {
    try {
      final user = await ApiService.login(email, password);
      if (user == null || user == 'Fail login') return false;
      state = user;
      return user;
    } catch (_) {
      return false;
    }
  }

  Future<bool> register(CreateUser newUser) async {
    try {
      final data = await ApiService.register(newUser);
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
      state = null;
      return true;
    } catch (err) {
      return false;
    }
  }
}
