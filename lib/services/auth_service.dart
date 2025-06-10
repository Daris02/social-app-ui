import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

final authProvider = StateNotifierProvider<AuthController, User?>(
  (ref) => AuthController(),
);

class AuthController extends StateNotifier<User?> {
  AuthController() : super(null) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final lastName = prefs.getString('lastName');
    final email = prefs.getString('email');
    final id = prefs.getInt('id');
    if (token != null && lastName != null && id != null && email != null) {
      state = User(id: id, lastName: lastName, email: email, token: token);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final data = await ApiService.login(email, password);
      final user = User.fromJson(data);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', user.token);
      await prefs.setString('lastName', user.lastName);
      await prefs.setString('email', user.email);
      await prefs.setInt('id', user.id);

      state = user;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> register(String lastName, String email, String password) async {
    try {
      final data = await ApiService.register(lastName, email, password);
      if (data == null) {
        return false;
      }
      if (data["message"] != 'Inscription réussie') {
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
