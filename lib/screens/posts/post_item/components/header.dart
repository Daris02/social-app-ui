import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/models/post.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/providers/ws_provider.dart';
import 'package:social_app/routes/app_router.dart';
import 'package:social_app/services/post_service.dart';

class PostItemHeader extends ConsumerWidget {
  const PostItemHeader({
    super.key,
    required this.post,
    required this.colorSchema,
    required this.currentUser,
    required this.author,
    required this.dateStr,
  });

  final Post post;
  final ColorScheme colorSchema;
  final User currentUser;
  final User author;
  final String dateStr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref
        .watch(webSocketServiceProvider)
        .isConnected(post.author.id);
    final router = ref.read(appRouterProvider);
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            child: (post.author.photo == null || post.author.photo == '')
                ? Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isOnline ? Colors.green : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.account_circle_outlined,
                            size: 35,
                            color: colorSchema.inversePrimary,
                          ),
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorSchema.inversePrimary,
                          border: Border.all(
                            color: isOnline ? Colors.green : Colors.grey,
                            width: 2,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(post.author.photo!),
                            fit: BoxFit.cover,
                            onError: (error, stackTrace) {
                              if (kDebugMode) {
                                debugPrint(
                                  'Error loading author photo: $error',
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    final isMe = currentUser.id == author.id;
                    if (isMe) {
                      router.push('/settings');
                    } else {
                      router.push('/profile', extra: author);
                    }
                  },
                  child: Text(
                    "${author.firstName} ${author.lastName}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  dateStr,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'edit') {
                // TODO: Navigue vers l'édition
              } else if (value == 'delete') {
                await PostService.deletePost(post.id);
                // setState(() {
                //   posts.removeWhere((p) => p.id == post.id);
                // });
              } else if (value == 'save') {
                // TODO: Enregistrer le post
              }
            },
            itemBuilder: (context) {
              if (author.id == currentUser.id) {
                return [
                  const PopupMenuItem(value: 'edit', child: Text('Modifier')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Supprimer'),
                  ),
                ];
              } else {
                return [
                  const PopupMenuItem(
                    value: 'save',
                    child: Text('Enregistrer'),
                  ),
                ];
              }
            },
            icon: const Icon(Icons.more_horiz),
          ),
        ],
      ),
    );
  }
}
