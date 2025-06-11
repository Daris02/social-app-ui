import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import '../services/api_service.dart';

final postProvider = FutureProvider<List<Post>>((ref) async {
  return await ApiService.getPosts();
});
