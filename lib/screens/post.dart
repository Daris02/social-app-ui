import 'package:flutter/material.dart';
import 'package:social_app/components/PostComponent.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/models/post.dart';
import '../services/api_service.dart';

class PostScreen extends ConsumerStatefulWidget {
  const PostScreen({super.key});

  @override
  ConsumerState<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  bool onSearch = false;
  bool isLoading = false;
  bool showSearchBar = false;
  List filteredPosts = [];
  late List<Post> posts = [];
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPosts();
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge &&
          _scrollController.position.pixels != 0) {
        if (!isLoading) {
          fetchPosts();
        }
      }
    });
  }

  void fetchPosts() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
    });
    List<Post> data = await ApiService.getPosts();
    setState(() {
      posts.addAll(data);
      filteredPosts = posts;
      isLoading = false;
    });
  }

  void filterPosts(String query) {
    setState(() {
      onSearch = query.isNotEmpty;
      filteredPosts =
          posts
              .where(
                (post) => post.content
                    .toLowerCase()
                    .toString()
                    .contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Nouvelle Publications"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Titre"),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: "Contenue"),
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
              _titleController.clear();
              _contentController.clear();
              Navigator.pop(context);
            },
            child: Text("Publier"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title:
            showSearchBar
                ? TextField(
                  controller: searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Search posts...",
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
                : Text("Publications"),
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
            icon: Icon(Icons.add_box_outlined),
            onPressed: () => _showCreateDialog(context, ref),
            tooltip: 'Create Post',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                (!onSearch && posts.isEmpty)
                    ? Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                    : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: filteredPosts.length,
                              itemBuilder: (context, index) {
                                return PostComponent(
                                  title: filteredPosts[index].title,
                                  content: filteredPosts[index].content,
                                  author: filteredPosts[index].author
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
          ),
        ],
      ),
      
      // ListView.builder(
      //   itemCount: posts.length,
      //   itemBuilder: (context, index) {
      //   return MySquare();
      // })
      
      // posts.when(
      //   data: (data) => data.isEmpty ? Text('No post') : ListView.builder(
      //     itemCount: data.length,
      //     itemBuilder: (_, i) {
      //       final a = data[i];
      //       return ListTile(
      //         title: Text(a.title),
      //         subtitle: Text("${a.content}\nAuteur: ${a.author.lastName}"),
      //         isThreeLine: true,
      //       );
      //     },
      //   ),
      //   loading: () => Center(child: CircularProgressIndicator()),
      //   error: (e, _) {
      //     print("Erreur lors du chargement des publications: $e");
      //     return Center(child: Text("Erreur de chargement"));
      //   },
      // ),
    );
  }
}
