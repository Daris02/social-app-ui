import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_app/constant/api.dart';
import 'package:social_app/models/user.dart';

final dio = Dio(
  BaseOptions(baseUrl: baseApiUrl, contentType: 'application/json'),
);

class AuthService {
  static dynamic login(String email, String password) async {
    try {
      final res = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      if (res.data['message'] != 'Login successful') return "Fail login";
      final token = res.data['token'];
      final userData = res.data['user'];
      final user = User.fromJson(userData);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token);
      user.token = token;
      return user;
    } catch (e) {
      if (kDebugMode) {
        print('Error during login: $e');
      }
      return false;
    }
  }

  static dynamic register(CreateUser newUser) async {
    try {
      final res = await dio.post(
        '/auth/register',
        data: {
          'firstName': newUser.firstName,
          'lastName': newUser.lastName,
          'email': newUser.email,
          'IM': newUser.IM,
          'password': newUser.password,
          'confirmPassword': newUser.confirmPassword,
          'phone': newUser.phone,
          'address': newUser.address,
          'position': newUser.position,
          'attribution': newUser.attribution,
          'direction': newUser.direction,
          'service': newUser.service,
          'entryDate': newUser.entryDate.toString(),
        },
      );
      if (res.data['message'] != "User registered") return "Fail registration";
      return res.data;
    } catch (e) {
      if (kDebugMode) {
        print('Error during registration: $e');
      }
      return false;
    }
  }
}