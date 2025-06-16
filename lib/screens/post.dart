import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/models/post.dart';
import 'package:social_app/providers/post_provider.dart';
import 'package:social_app/services/api_service.dart';
import '../components/PostComponent.dart';

class PostScreen extends ConsumerStatefulWidget {
  const PostScreen({super.key});

  @override
  ConsumerState<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  bool showSearchBar = false;
  bool isLoading = false;
  List<Post> posts = [];
  List<Post> filteredPosts = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  void fetchPosts() async {
    setState(() => isLoading = true);
    final data = await ApiService.getPosts();
    setState(() {
      posts = data;
      filteredPosts = data;
      isLoading = false;
    });
  }

  void filterPosts(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredPosts = posts;
      } else {
        filteredPosts = posts
            .where(
              (post) =>
                  post.title.toLowerCase().contains(query.toLowerCase()) ||
                  post.content.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: showSearchBar
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Rechercher...",
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        showSearchBar = false;
                        searchController.clear();
                        filteredPosts = posts;
                      });
                    },
                  ),
                ),
                onChanged: filterPosts,
              )
            : const Text("Publications"),
        actions: [
          if (!showSearchBar)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  showSearchBar = true;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () => _showCreateDialog(context, ref),
            tooltip: 'Créer une publication',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredPosts.isEmpty
          ? const Center(child: Text('Aucun résultat'))
          : ListView.builder(
              itemCount: filteredPosts.length,
              itemBuilder: (context, index) {
                final post = filteredPosts[index];
                return PostComponent(post: post, author: post.author);
              },
            ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final _titleController = TextEditingController();
    final _contentController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nouvelle Publication"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Titre"),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: "Contenu"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ApiService.createPost(
                _titleController.text,
                _contentController.text,
              );
              ref.refresh(postsProvider);
              Navigator.pop(context);
            },
            child: const Text("Publier"),
          ),
        ],
      ),
    );
  }
}
