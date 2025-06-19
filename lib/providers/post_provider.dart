import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/models/post.dart';
import 'package:social_app/services/post_service.dart';

final postsProvider = FutureProvider<List<Post>>((ref) async {
  return await PostService.getPosts();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredPostsProvider = Provider<List<Post>>((ref) {
  final postsAsync = ref.watch(postsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  return postsAsync.maybeWhen(
    data: (posts) {
      if (query.isEmpty) return posts;
      return posts.where((post) =>
        post.title.toLowerCase().contains(query) ||
        post.content.toLowerCase().contains(query)
      ).toList();
    },
    orElse: () => [],
  );
});