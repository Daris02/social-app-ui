import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_app/constant/api.dart';
import 'package:social_app/models/direction.dart';
import 'package:social_app/models/message.dart';
import 'package:social_app/models/post.dart';
import 'package:social_app/models/user.dart';

final dio = Dio(
  BaseOptions(baseUrl: baseApiUrl, contentType: 'application/json'),
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
      final userData = res.data['user'];
      final user = User.fromJson(userData);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token);
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
          'service': newUser.service,
          'entryDate': newUser.entryDate.toString(),
        },
      );
      if (res.data['message'] != "User registered") return "Fail registration";
      return res.data;
    } catch (e) {
      print('Error during registration: $e');
      return false;
    }
  }

  static Future<List<User>> getContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await dio.get(
      '/users/contacts',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (res.data as List).map((e) => User.fromJson(e)).toList();
  }

  static Future<List<Direction>> getDirections() async {
    final res = await dio.get('/directions');
    return (res.data as List).map((e) => Direction.fromJson(e)).toList();
  }

  static Future<List<Post>> getPosts() async {
    final res = await dio.get('/posts');
    return (res.data as List).map((e) => Post.fromJson(e)).toList();
  }

  static Future<void> createPost(String title, String content) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await dio.post(
      '/posts',
      data: {'title': title, 'content': content},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  static Future<void> likePost(int id, String reaction) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await dio.post(
      '/posts/$id/reactions',
      data: {'reactionType': reaction},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  static Future<void> deletePost(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await dio.delete(
      '/posts/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  static Future<List<Message>> getMessages(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await dio.get(
      '/messages/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final data = response.data;

    if (data is List) {
      return data.map((e) => Message.fromJson(e)).toList();
    } else {
      throw Exception('Format de réponse inattendu: ${data.runtimeType}');
    }
  }
}
