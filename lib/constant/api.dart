// dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DioClient {
  static late Dio dio;
  static late String baseApiUrl;
  static late String baseSocket;

  static void init() {
    final env = dotenv.env['ENV'];
    final host = dotenv.env['HOST'];
    final hostProd = dotenv.env['HOST_PROD'];

    final baseApiUrlLocal = 'http://$host:4000';
    final baseApiUrlProd = 'https://$hostProd';
    baseApiUrl = env == 'dev' ? baseApiUrlLocal : baseApiUrlProd;

    debugPrint('Base URL : $baseApiUrl');

    dio = Dio(
      BaseOptions(baseUrl: baseApiUrl, contentType: 'application/json'),
    );

    final baseSocketLocal = 'ws://$host:4000';
    final baseSocketProd = 'wss://$hostProd';
    baseSocket = env == 'dev' ? baseSocketLocal : baseSocketProd;
  }

  static Future<bool> ping() async {
    try {
      final response = await dio.get('');
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Error on ping server: ${e.message}');
      }
      return false;
    }
  }
}
