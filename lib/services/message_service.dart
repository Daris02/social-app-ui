import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_app/constant/api.dart';
import 'package:social_app/models/message.dart';

class MessageService {
  static final dio = DioClient.dio;

  static Future<List<Message>> getMessages(int partnerId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await dio.get(
      '/messages/$partnerId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    final data = response.data;
    if (data is List) {
      return data.map((e) => Message.fromJson(e)).toList();
    } else {
      throw Exception('Format de réponse inattendu: ${data.runtimeType}');
    }
  }

  static Future<List<String>> uploadFiles({
    required List<PlatformFile> files,
    Function(int sent, int total)? onUploadProgress,
  }) async {
    final formData = FormData.fromMap({
      'files': files.map((f) => MultipartFile.fromFileSync(
            f.path!,
            filename: f.name,
          )).toList(),
    });

    final response = await dio.post(
      '/upload/file',
      data: formData,
      onSendProgress: onUploadProgress,
    );

    return List<String>.from(response.data['urls']);
  }
}
