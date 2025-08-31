import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/models/post.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/screens/messages/chat_screen.dart';
import 'package:social_app/screens/posts/post_item/components/image_view.dart';
import 'package:social_app/screens/posts/post_item/post_item.dart';
import 'package:social_app/services/post_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late User user;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception(
        'Impossible d\'ouvrir le composeur téléphonique pour $phoneNumber',
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildProfileHeader(BuildContext context) {
    final colorSchema = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorSchema.primaryContainer,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (user.photo != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ImageViewerScreen(url: user.photo!),
                  ),
                );
              }
            },
            child: CircleAvatar(
              radius: 50,
              backgroundColor: colorSchema.inversePrimary.withOpacity(0.3),
              backgroundImage: user.photo != null
                  ? NetworkImage(user.photo!)
                  : null,
              onBackgroundImageError: (error, stackTrace) {
                if (kDebugMode) {
                  debugPrint('Error loading user photo: $error');
                }
              },
              child: user.photo == null
                  ? Icon(
                      Icons.person,
                      size: 50,
                      color: colorSchema.onPrimaryContainer,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "${user.firstName} ${user.lastName}",
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            user.attribution,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorSchema.primary,
                  foregroundColor: colorSchema.onPrimary,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(partner: user),
                    ),
                  );
                },
                icon: const Icon(Icons.message_rounded),
                label: const Text('Message'),
              ),
              const SizedBox(width: 12),
              Platform.isAndroid || Platform.isIOS ? ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await makePhoneCall(user.phone);
                },
                icon: const Icon(Icons.call),
                label: const Text('Téléphoner'),
              ) : const SizedBox(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostsTab() {
    return FutureBuilder<List<Post>>(
      future: PostService.getPostByAuthorId(user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          debugPrint('Error: ${snapshot.error.toString()}');
          return Center(
            child: Text("Erreur lors du chargement des publications"),
          );
        }
        final posts = snapshot.data ?? [];
        if (posts.isEmpty) {
          return const Center(child: Text("Aucune publication"));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) =>
              PostItem(post: posts[index], user: user, onDelete: (_) {}),
        );
      },
    );
  }

  Widget _buildInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.badge_outlined),
          title: const Text("Nom complet"),
          subtitle: Text("${user.firstName} ${user.lastName}"),
        ),
        ListTile(
          leading: const Icon(Icons.email_outlined),
          title: const Text("Email"),
          subtitle: Text(user.email),
        ),
        ListTile(
          leading: const Icon(Icons.phone_outlined),
          title: const Text("Téléphone"),
          subtitle: Text(user.phone),
        ),
        if (user.address.isNotEmpty)
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text("Adresse"),
            subtitle: Text(user.address),
          ),
        if (user.direction != null)
          ListTile(
            leading: const Icon(Icons.apartment_outlined),
            title: const Text("Direction"),
            subtitle: Text(user.direction!.name),
          ),
        ListTile(
          leading: const Icon(Icons.calendar_today_outlined),
          title: const Text("Date d'entrée"),
          subtitle: Text("${user.entryDate.toLocal()}".split(' ')[0]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: Column(
        children: [
          _buildProfileHeader(context),
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabs: const [
                Tab(icon: Icon(Icons.article_outlined), text: "Publications"),
                Tab(icon: Icon(Icons.info_outline), text: "Informations"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildPostsTab(), _buildInfoTab()],
            ),
          ),
        ],
      ),
    );
  }
}
