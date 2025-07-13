import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/providers/user_provider.dart';
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

  @override
  void initState() {
    super.initState();
    firstLoad();
    _scrollController.addListener(scrollListener);
  }

  void firstLoad() async {
    setState(() {
      isFirstLoadRunning = true;
    });
    fetchPosts();
    setState(() {
      isFirstLoadRunning = false;
    });
  }

  void loadMore() {
    if (hasNextPage == true && isLoadMoreRunning == false) {
      setState(() {
        isLoadMoreRunning = true;
      });
    }

    // Timer(Duration(seconds: 3), () {});
    fetchPosts();

    setState(() {
      isLoadMoreRunning = false;
    });
  }

  Future<void> fetchPosts() async {
    final fetchPosts = await PostService.getPosts(page, 5);
    if (fetchPosts.isNotEmpty) {
      setState(() {
        page++;
        posts.addAll(fetchPosts);
      });
    } else {
      setState(() {
        hasNextPage = false;
      });
    }
  }

  void scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      fetchPosts();
    } else {
      setState(() {
        hasNextPage = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Publications"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreatePostScreen()),
              ).then((_) => fetchPosts());
            },
          ),
        ],
      ),
      body: isFirstLoadRunning
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    controller: _scrollController,
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return PostView(post: post, user: user!);
                    },
                  ),
                ),
                if (isLoadMoreRunning == true)
                  Container(
                    padding: EdgeInsets.only(top: 10, bottom: 40),
                    color: Colors.white,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (hasNextPage == false)
                  Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    color: Colors.black,
                    child: Center(child: Text('No more post')),
                  ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
