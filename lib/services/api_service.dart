import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_app/models/annonce.dart';
import 'package:social_app/models/user.dart';

final dio = Dio(
  BaseOptions(
    baseUrl: 'http://192.168.8.100:4000',
    // baseUrl: 'http://localhost:40   // baseUrl: 'http://192.168.0.53:4000',
    // baseUrl: 'http://192.168.88.201:4000',
    // baseUrl: 'http://192.168.112.12:4000',
    contentType: 'application/json',
  ),
);

class ApiService {
  static dynamic login(String email, String password) async {
    try {
      final res = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      if (res.data['message'] != 'Login successful') return "Fail login";
      final token = res.data['token'];
      final user = User.fromJson(res.data['user']);
      user.token = token;
      return user;
    } catch (e) {
      print('Error during login: $e');
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
          'entryDate': newUser.entryDate.toString(),
          'senator': newUser.senator,
        },
      );
      if (res.data['message'] != "User registered") return "Fail registration";
      return res.data;
    } catch (e) {
      print('Error during registration: $e');
      return false;
    }
  }

  static Future<List<Annonce>> getAnnonces() async {
    final res = await dio.get('/posts');
    return (res.data as List).map((e) => Annonce.fromJson(e)).toList();
  }

  static Future<void> createAnnonce(String title, String content) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await dio.post(
      '/posts',
      data: {'title': title, 'content': content},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
