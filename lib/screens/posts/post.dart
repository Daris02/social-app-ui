import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/constant/helpers.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/routes/app_router.dart';
import 'package:social_app/screens/posts/components/create_post.dart';
import 'package:social_app/models/post.dart';
import 'package:social_app/screens/posts/components/post_view.dart';
import 'package:social_app/services/post_service.dart';

class PostScreen extends ConsumerStatefulWidget {
  const PostScreen({super.key});

  @override
  ConsumerState<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  bool hasNextPage = true;
  bool isLoadMoreRunning = false;
  bool isFirstLoadRunning = false;

  int page = 1;
  List<Post> posts = [];

  final ScrollController _scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  final FocusNode _keyboardFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    firstLoad();
    _scrollController.addListener(scrollListener);
  }

  void firstLoad() async {
    setState(() => isFirstLoadRunning = true);
    await refreshPosts();
    setState(() => isFirstLoadRunning = false);
  }

  Future<void> loadMore() async {
    if (!hasNextPage || isLoadMoreRunning) return;

    setState(() => isLoadMoreRunning = true);

    final fetched = await PostService.getPosts(page, 5);

    if (fetched.isNotEmpty) {
      setState(() {
        page++;
        posts.addAll(fetched);
      });
    } else {
      setState(() => hasNextPage = false);
    }

    setState(() => isLoadMoreRunning = false);
  }

  Future<void> refreshPosts() async {
    setState(() {
      posts = [];
      page = 1;
      hasNextPage = true;
    });

    final freshPosts = await PostService.getPosts(page, 5);
    setState(() {
      posts = freshPosts;
      page++;
    });
  }

  void scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      loadMore();
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.f5) {
        refreshPosts();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final router = ref.read(appRouterProvider);
    return KeyboardListener(
      focusNode: _keyboardFocus..requestFocus(),
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Publications"),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                ).then((_) => refreshPosts());
              },
            ),
          ],
        ),
        drawer: isDesktop(context) ? null : myDrawer(context, router, userProvider),
        body: isFirstLoadRunning
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: refreshPosts,
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: posts.length + 1,
                  itemBuilder: (context, index) {
                    if (index < posts.length) {
                      return PostView(
                        key: PageStorageKey(posts[index].id),
                        post: posts[index],
                        user: user!,
                      );
                    } else if (isLoadMoreRunning) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (!hasNextPage) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: Text('Aucune autre publication')),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _keyboardFocus.dispose();
    super.dispose();
  }
}
