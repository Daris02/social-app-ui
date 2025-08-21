import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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

  static Future<List<Post>?> searchPosts(String search) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final res = await DioClient.dio.get(
        '/posts/search?query=$search',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return (res.data as List).map((e) => Post.fromJson(e)).toList();
    } on DioException {
      return [];
    }
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

  static Future<List<Post>> getPostByAuthorId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await DioClient.dio.get(
      '/posts/author/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (res.data as List).map((e) => Post.fromJson(e)).toList();
  }

  static Future<void> createPost(
    String title,
    String content, {
    List<PlatformFile>? files,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final formData = FormData.fromMap({
      'title': title,
      'content': content,
      'files': files?.map(
              (file) =>
                  MultipartFile.fromFileSync(file.path!, filename: file.name),
            ).toList(),
    });

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
  }

  static Future<void> deletePost(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await dio.delete(
      '/posts/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  static Future<void> downloadMedia(String url, {String? filename}) async {
    try {
      // Demande de permission sur Android
      if (!kIsWeb && Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('Permission refusée');
        }
      }

      final fileName = filename ?? url.split('/').last;
      final dir = !kIsWeb && Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getDownloadsDirectory();

      if (dir == null) throw Exception("Impossible de trouver un dossier.");

      final savePath = '${dir.path}/$fileName';
      final dio = Dio();

      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            debugPrint(
              'Téléchargement: ${(received / total * 100).toStringAsFixed(0)}%',
            );
          }
        },
      );

      debugPrint('✅ Fichier sauvegardé dans $savePath');
    } catch (e) {
      debugPrint('❌ Erreur de téléchargement: $e');
    }
  }

  // REACTION METHOD ---
  static Future<List<Reaction>> getReactionsByPostId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await DioClient.dio.get(
      '/posts/$id/reactions',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (res.data as List).map((e) => Reaction.fromJson(e)).toList();
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

  // COMMENT METHOD ---
  static Future<List<Comment>> getCommentsByPostId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final res = await DioClient.dio.get(
      '/posts/$id/comments',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (res.data as List).map((e) => Comment.fromJson(e)).toList();
  }

  static Future<void> commentPost(
    int postId,
    int userId,
    String commentContent,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await dio.post(
      '/posts/$postId/comments',
      data: {'content': commentContent},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  static Future<void> removeComment(int postId, int commentId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await dio.delete(
      '/posts/$postId/comments/$commentId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
