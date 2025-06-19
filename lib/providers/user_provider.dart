import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

final userProvider = StateNotifierProvider<UserController, User?>((ref) {
  return UserController();
});

class UserController extends StateNotifier<User?> {
  static const _userKey = 'current_user';

  UserController() : super(null) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      final userMap = jsonDecode(userData);
      state = User.fromJson(userMap);
    }
  }

  Future<void> setUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    state = user;
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    state = null;
  }
}
