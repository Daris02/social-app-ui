import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_app/constant/api.dart';
import 'package:social_app/models/message.dart';

class MessageService {
  static final dio = DioClient.dio;

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