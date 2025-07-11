import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_app/constant/api.dart';
import 'package:social_app/models/user.dart';

class UserService {
  static final dio = DioClient.dio;

  static Future<List<User>> getContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await dio.get(
      '/users/contacts',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (res.data as List).map((e) => User.fromJson(e)).toList();
  }
 
  static Future<User?> getUserById(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await dio.get(
      '/users/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return User.fromJson(res as Map<String, dynamic>);
  }
 
  static Future<User> updateUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await dio.patch(
      '/users/${user.id}',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return User.fromJson(res as Map<String, dynamic>);
  }
}