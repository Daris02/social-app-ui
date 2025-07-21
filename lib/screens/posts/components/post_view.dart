import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:social_app/models/enums/reaction_type.dart';
import 'package:social_app/models/post.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/providers/ws_provider.dart';
import 'package:social_app/screens/posts/components/video_player/video_player.dart';
import 'package:social_app/screens/posts/components/image_view.dart';
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
  final TextEditingController _commentController = TextEditingController();

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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final dateStr = DateFormat('dd MMM yyyy à HH:mm').format(post.createdAt);
    // final isOnline = ref
    //     .watch(webSocketServiceProvider)
    //     .isConnected(post.author.id);
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
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ImageViewerScreen(url: url),
                                  ),
                                );
                              },
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
                                        value:
                                            progress.expectedTotalBytes != null
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
                            ),
                            // Positioned(
                            //   top: 8,
                            //   right: 8,
                            //   child: IconButton(
                            //     icon: const Icon(
                            //       Icons.download,
                            //       color: Colors.white,
                            //     ),
                            //     onPressed: () => PostService.downloadMedia(url),
                            //   ),
                            // ),
                          ],
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            VideoPlayerScreen(url: url),
                                      ),
                                    );
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
                      return const SizedBox();
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

  void commentPost() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Commentaires',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: post.comments.isEmpty
                    ? const Center(child: Text("Aucun commentaire"))
                    : ListView.builder(
                        itemCount: post.comments.length,
                        itemBuilder: (context, index) {
                          final comment = post.comments[index];
                          final isMyComment = comment.user.id == currentUser.id;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: comment.user.photo != null
                                  ? NetworkImage(comment.user.photo!)
                                  : null,
                              child: comment.user.photo == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(
                              "${comment.user.firstName} ${comment.user.lastName}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(comment.content),
                            trailing: isMyComment
                                ? PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        final edited = await showDialog<String>(
                                          context: context,
                                          builder: (context) {
                                            final controller =
                                                TextEditingController(
                                                  text: comment.content,
                                                );
                                            return AlertDialog(
                                              title: const Text(
                                                'Modifier le commentaire',
                                              ),
                                              content: TextField(
                                                controller: controller,
                                                decoration:
                                                    const InputDecoration(
                                                      hintText:
                                                          'Votre commentaire...',
                                                    ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('Annuler'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    final newContent =
                                                        controller.text.trim();
                                                    Navigator.pop(
                                                      context,
                                                      newContent,
                                                    );
                                                  },
                                                  child: const Text('Modifier'),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (edited != null &&
                                            edited != comment.content) {
                                          // await PostService.updateComment(
                                          //   comment.id,
                                          //   edited,
                                          // );
                                          final updated =
                                              await PostService.getPostById(
                                                post.id,
                                              );
                                          setState(() {
                                            post = updated;
                                          });
                                        }
                                      } else if (value == 'delete') {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text(
                                              'Supprimer ce commentaire ?',
                                            ),
                                            content: const Text(
                                              'Cette action est irréversible.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                                child: const Text('Annuler'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                                child: const Text('Supprimer'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          await PostService.removeComment(
                                            post.id,
                                            comment.id,
                                          );

                                          final comments =
                                              await PostService.getCommentsByPostId(
                                                post.id,
                                              );
                                          setState(() {
                                            post.comments = comments;
                                            totalComment = comments.length;
                                          });
                                          Navigator.pop(context);
                                          commentPost();
                                        }
                                      }
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Modifier'),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Supprimer'),
                                      ),
                                    ],
                                    icon: const Icon(Icons.more_vert),
                                  )
                                : null,
                          );
                        },
                      ),
              ),
              const Divider(),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: "Ajouter un commentaire...",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      final content = _commentController.text.trim();
                      if (content.isNotEmpty) {
                        await PostService.commentPost(
                          post.id,
                          currentUser.id,
                          content,
                        );
                        _commentController.clear();

                        final comments = await PostService.getCommentsByPostId(
                          post.id,
                        );
                        setState(() {
                          post.comments = comments;
                          totalComment = comments.length;
                        });
                        Navigator.pop(context);
                        commentPost();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
