import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_app/models/post.dart';
import 'package:social_app/constant/api.dart';
import 'package:social_app/models/comment.dart';
import 'package:social_app/models/reaction.dart';
import 'package:social_app/models/enums/reaction_type.dart';

class PostService {
  static final dio = DioClient.dio;

  static Future<List<Post>> getPosts(int? page, int? limit) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await DioClient.dio.get(
      '/posts?page=$page&limit=$limit',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (res.data['items'] as List).map((e) => Post.fromJson(e)).toList();
  }

  static Future<Post> getPostById(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await DioClient.dio.get(
      '/posts/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return Post.fromJson(res.data);
  }

  static Future<List<Reaction>> getReactionsByPostId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await DioClient.dio.get(
      '/posts/$id/reactions',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (res.data as List).map((e) => Reaction.fromJson(e)).toList();
  }

  static Future<List<Comment>> getCommentsByPostId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await DioClient.dio.get(
      '/posts/$id/comments',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (res.data as List).map((e) => Comment.fromJson(e)).toList();
  }

  static Future<void> createPost(
    String title,
    String content, {
    PlatformFile? file,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final formData = FormData();

    formData.fields.addAll([
      MapEntry('title', title),
      MapEntry('content', content),
    ]);

    if (file != null && file.path != null) {
      final mimeType = lookupMimeType(file.path!) ?? 'application/octet-stream';

      formData.files.add(
        MapEntry(
          'files',
          await MultipartFile.fromFile(
            file.path!,
            filename: file.name,
            contentType: MediaType.parse(mimeType),
          ),
        ),
      );
    }

    var result = await dio.post(
      '/posts/upload',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
    debugPrint('Result: ${result.data}');
  }

  static Future<void> likePost(
    int id,
    int userId,
    ReactionType reaction,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await dio.post(
      '/posts/$id/reactions',
      data: {'reactionType': reaction.name},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  static Future<void> unlikePost(int id, int likeId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await dio.delete(
      '/posts/$id/reactions/$likeId',
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
