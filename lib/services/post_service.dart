import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_app/constant/api.dart';
import 'package:social_app/models/post.dart';

class PostService {
  static final dio = DioClient.dio;
  
  static Future<List<Post>> getPosts() async {
    final res = await DioClient.dio.get('/posts');
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
}