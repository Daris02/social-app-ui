import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_app/constant/api.dart';
import 'package:social_app/models/create_user.dart';
import 'package:social_app/models/user.dart';

class AuthService {
  static final dio = DioClient.dio;

  static dynamic login(String email, String password) async {
    try {
      final res = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      if (res.statusCode != 201) return "Fail login";
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
          'position': newUser.position?.name,
          'attribution': newUser.attribution,
          'direction': newUser.direction.name,
          'service': newUser.service,
          'entryDate': newUser.entryDate.toString(),
        },
      );
      if (res.statusCode == 201) return true;
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        if (kDebugMode) print('Email déjà utilisé.');
        return 'email_exists';
      } else if (e.response?.statusCode == 400) {
        if (kDebugMode) print('Erreur de validation: ${e.response?.data}');
        return 'validation_error';
      }
      if (kDebugMode) print('Erreur serveur: $e');
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error during registration: $e');
      }
      return false;
    }
  }

  static dynamic whoami(String token) async {
    try {
      final res = await dio.post(
        '/auth/whoami',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return res.data;
    } catch (e) {
      if (kDebugMode) {
        print('Error during login: $e');
      }
      return false;
    }
  }
}
