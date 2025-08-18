import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/constant/helpers.dart';
import 'package:social_app/models/post.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/routes/app_router.dart';
import 'package:social_app/screens/posts/post_item/post_item.dart';
import 'package:social_app/screens/search/components/card_user.dart';
import 'package:social_app/services/post_service.dart';
import 'package:social_app/services/user_service.dart';
import 'package:social_app/utils/main_drawer.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String valueSearch;
  const SearchScreen({super.key, required this.valueSearch});

  @override
  ConsumerState createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Post>> _postsFuture;
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    initSearch();
  }

  initSearch() {
    _postsFuture = PostService.searchPosts(
      widget.valueSearch,
    ).then((value) => value ?? []);
    _usersFuture = UserService.searchUsers(
      widget.valueSearch,
    ).then((value) => value ?? []);
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant SearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.valueSearch != widget.valueSearch) {
      _postsFuture = PostService.searchPosts(
        widget.valueSearch,
      ).then((value) => value ?? []);
      _usersFuture = UserService.searchUsers(
        widget.valueSearch,
      ).then((value) => value ?? []);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider);
    final router = ref.read(appRouterProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Recherche'),
        bottom: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 2.0,
              ),
            ),
          ),
          tabs: const [
            Tab(text: 'Publications'),
            Tab(text: 'Personnes'),
          ],
        ),
      ),
      drawer: isDesktop(context) ? null : MainDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          FutureBuilder<List<Post>>(
            future: _postsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Erreur lors de la recherche de posts'),
                );
              }
              final posts = snapshot.data ?? [];
              if (posts.isEmpty) {
                return Center(
                  child: Text(
                    'Aucune publication trouvé pour "${widget.valueSearch}"',
                  ),
                );
              }
              return Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return PostItem(post: post, user: user!);
                    },
                  ),
                ),
              );
            },
          ),
          FutureBuilder<List<User>>(
            future: _usersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Erreur lors de la recherche de personnes'),
                );
              }
              final users = snapshot.data ?? [];
              if (users.isEmpty) {
                return Center(
                  child: Text(
                    'Aucune personne trouvée pour "${widget.valueSearch}"',
                  ),
                );
              }
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: CardUser(user: user, router: router),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
