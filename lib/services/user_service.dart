import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_app/constant/api.dart';
import 'package:social_app/models/direction.dart';
import 'package:social_app/models/user.dart';

final dio = Dio(
  BaseOptions(baseUrl: baseApiUrl, contentType: 'application/json'),
);

class UserService {
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
}