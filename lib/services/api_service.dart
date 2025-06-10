import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_app/models/annonce.dart';

final dio = Dio(
  BaseOptions(
    // baseUrl: 'http://192.168.8.100:4000',
    // baseUrl: 'http://localhost:4000',
    baseUrl: 'http://192.168.0.53:4000',
    // baseUrl: 'http://192.168.88.201:4000',
    // baseUrl: 'http://192.168.112.12:4000',
    contentType: 'application/json',
  )
);

class ApiService {
  static dynamic login(String email, String password) async {
    try {
      final res = await dio.post('/auth/login', data: {'email': email, 'password': password});
      if (res.data['message'] != 'Login successful') return "Fail login";
      return res.data;
    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }

  static dynamic register(String username, String email, String password) async {
    try {
      final res = await dio.post('/auth/register', data: {'username': username, 'email': email, 'password': password});
      if (res.data == null) return "Fail register";
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
