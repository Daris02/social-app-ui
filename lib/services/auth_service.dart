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

  static Future<String> register(CreateUser newUser) async {
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
      debugPrint('Response: ${res.data}');
      return 'user_created';
    } on DioException catch (e) {
      if (e.response?.statusCode == 201) {
        return 'user_created';
      }
      if (e.response?.statusCode == 409) {
        return 'email_exists';
      } else if (e.response?.statusCode == 400) {
        return 'validation_error: ${e.response?.data}';
      }
      return 'server_error';
    } catch (e) {
      return 'error_during_user_creation';
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

  static dynamic verifyEmailWithCode(String email, String code) async {
    try {
      final res = await dio.post(
        '/auth/verify-email',
        data: {'email': email, 'code': code},
      );
      return res.statusCode == 201;
    } catch (e) {
      if (kDebugMode) {
        print('Error during verification email with code: $e');
      }
      return false;
    }
  }

  static dynamic resendCode(String email) async {
    try {
      final res = await dio.post(
        '/auth/resend-code',
        data: {'email': email},
      );
      return res.statusCode == 201;
    } catch (e) {
      if (kDebugMode) {
        print('Error during resending code to email with code: $e');
      }
      return false;
    }
  }

  static dynamic forgotPassword(String email) async {
    try {
      final res = await dio.post(
        '/auth/password-forgot',
        data: {'email': email},
      );
      return res.statusCode;
    } catch (e) {
      if (kDebugMode) {
        print('Error during forgot password: $e');
      }
      return false;
    }
  }

  static dynamic resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      final res = await dio.post(
        '/auth/verify-email',
        data: {'email': email, 'code': code, 'newPassword': newPassword},
      );
      return res.statusCode;
    } catch (e) {
      if (kDebugMode) {
        print('Error during reset password: $e');
      }
      return false;
    }
  }
}
