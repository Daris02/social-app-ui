import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:social_app/models/enums/reaction_type.dart';
import 'package:social_app/models/post.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/providers/ws_provider.dart';
import 'package:social_app/services/post_service.dart';

class PostView extends ConsumerStatefulWidget {
  final Post post;
  final User user;

  const PostView({super.key, required this.post, required this.user});

  @override
  ConsumerState<PostView> createState() => _PostViewState();
}

class _PostViewState extends ConsumerState<PostView>
    with AutomaticKeepAliveClientMixin {
  bool isLiked = false;
  late Post post;
  late User author;
  late final User currentUser;
  int totalReaction = 0;
  int totalComment = 0;
  late final WebSocketService socket;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    post = widget.post;
    author = post.author;
    currentUser = widget.user;

    fetchData();

    socket = ref.read(webSocketServiceProvider);
    socket.onPostUpdated((postId) async {
      if (!mounted) return;
      if (postId == post.id) {
        final updated = await PostService.getPostById(post.id);
        final reactions = await PostService.getReactionsByPostId(post.id);
        final comments = await PostService.getCommentsByPostId(post.id);
        setState(() {
          updated.comments = comments;
          updated.reactions = reactions;
          isLiked = updated.reactions.any(
            (reaction) => reaction.user.id == currentUser.id,
          );
          totalReaction = reactions.length;
          totalComment = comments.length;
        });
      }
    });
  }

  void fetchData() async {
    if (!mounted) return;
    final reactions = await PostService.getReactionsByPostId(post.id);
    final comments = await PostService.getCommentsByPostId(post.id);
    post.comments = comments;
    post.reactions = reactions;
    totalReaction = post.reactions.length;
    totalComment = post.comments.length;
    isLiked = post.reactions.any(
      (reaction) => reaction.user.id == currentUser.id,
    );
    if (!mounted) return;
    setState(() {});
  }

  Future<void> toggleLike() async {
    if (!isLiked) {
      await PostService.likePost(post.id, currentUser.id, ReactionType.LIKE);
      socket.sendPostUpdate(currentUser.id.toString(), post.id);
      setState(() {
        totalReaction++;
        isLiked = true;
      });
    } else {
      await PostService.unlikePost(post.id, currentUser.id);
      socket.sendPostUpdate(currentUser.id.toString(), post.id);
      setState(() {
        totalReaction--;
        isLiked = false;
      });
    }
  }

  void commentPost() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Commentaire'),
        // content: SizedBox(
        //   height: 100,
        //   child: ListView.builder(
        //     itemCount: post.comments.length,
        //     itemBuilder: (context, index) {
        //       return ListTile(leading: Text(post.comments[index].content),);
        //     },
        //   ),
        // ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final dateStr = DateFormat('dd MMM yyyy à HH:mm').format(post.createdAt);
    final isOnline = ref
        .watch(webSocketServiceProvider)
        .isConnected(post.author.id);
    final colorSchema = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      child:
                          (post.author.photo == null || post.author.photo == '')
                          ? Stack(
                              children: [
                                Icon(
                                  Icons.account_circle_outlined,
                                  size: 40,
                                  color: colorSchema.inversePrimary,
                                ),
                                if (isOnline)
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
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
                                    image: DecorationImage(
                                      image: NetworkImage(post.author.photo!),
                                      fit: BoxFit.cover,
                                      onError: (error, stackTrace) {
                                        if (kDebugMode) {
                                          debugPrint(
                                            'Error loading authot photo: $error',
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                if (isOnline)
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
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
                          Text(
                            "${author.firstName} ${author.lastName}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            dateStr,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
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
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Modifier'),
                            ),
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
              ),

              // Media
              if (post.mediaUrls != null && post.mediaUrls!.isNotEmpty)
                Column(
                  children: post.mediaUrls!.map((url) {
                    final isImage =
                        url.endsWith('.jpg') ||
                        url.endsWith('.jpeg') ||
                        url.endsWith('.png') ||
                        url.endsWith('.gif');
                    final isVideo =
                        url.endsWith('.mp4') ||
                        url.endsWith('.webm') ||
                        url.endsWith('.mov');

                    if (isImage) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            url,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                height: 200,
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(
                                  value: progress.expectedTotalBytes != null
                                      ? progress.cumulativeBytesLoaded /
                                            progress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 100),
                          ),
                        ),
                      );
                    } else if (isVideo) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Stack(
                          children: [
                            Container(
                              height: 200,
                              width: double.infinity,
                              color: Colors.black12,
                              child: const Center(
                                child: Icon(
                                  Icons.videocam,
                                  size: 60,
                                  color: Colors.black45,
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    // TODO: Naviguer vers un lecteur vidéo
                                  },
                                  child: const Center(
                                    child: Icon(
                                      Icons.play_circle_fill,
                                      size: 64,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const SizedBox(); // Unsupported format
                    }
                  }).toList(),
                ),

              // Titre & contenu
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (post.title.isNotEmpty)
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (post.content.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(post.content),
                      ),
                  ],
                ),
              ),
              // Footer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                        color: isLiked ? Colors.blue : null,
                      ),
                      onPressed: toggleLike,
                    ),
                    Text('$totalReaction'),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.comment_outlined),
                      onPressed: commentPost,
                    ),
                    Text('$totalComment'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
