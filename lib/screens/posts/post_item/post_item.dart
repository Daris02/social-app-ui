import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:social_app/models/enums/reaction_type.dart';
import 'package:social_app/models/post.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/providers/ws_provider.dart';
import 'package:social_app/screens/posts/post_item/comment_post.dart';
import 'package:social_app/screens/posts/post_item/components/header.dart';
import 'package:social_app/screens/posts/post_item/components/media_view.dart';
import 'package:social_app/services/post_service.dart';

class PostItem extends ConsumerStatefulWidget {
  final Post post;
  final User user;
  final Function(int id) onDelete;

  const PostItem({
    super.key,
    required this.post,
    required this.user,
    required this.onDelete,
  });

  @override
  ConsumerState<PostItem> createState() => _PostItemState();
}

class _PostItemState extends ConsumerState<PostItem>
    with AutomaticKeepAliveClientMixin {
  bool isLiked = false;
  late Post post;
  late User author;
  late final User currentUser;
  int totalReaction = 0;
  int totalComment = 0;
  ReactionType? selectedReaction;
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
    selectedReaction = isLiked
        ? post.reactions
            .firstWhere((reaction) => reaction.user.id == currentUser.id).reactionType
        : null;
    if (!mounted) return;
    setState(() {});
  }

  Future<void> toggleLike(ReactionType reaction) async {
    if (!isLiked) {
      await PostService.likePost(post.id, currentUser.id, reaction);
      socket.sendPostUpdate(currentUser.id.toString(), post.id);
      setState(() {
        totalReaction++;
        isLiked = true;
        selectedReaction = reaction;
      });
    } else {
      await PostService.unlikePost(post.id, currentUser.id);
      socket.sendPostUpdate(currentUser.id.toString(), post.id);
      setState(() {
        totalReaction--;
        isLiked = false;
        selectedReaction = null;
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
    final colorSchema = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              PostItemHeader(
                post: post,
                colorSchema: colorSchema,
                currentUser: currentUser,
                author: author,
                dateStr: dateStr,
                onDelete: widget.onDelete,
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

              // Media
              if (post.mediaUrls != null && post.mediaUrls!.isNotEmpty)
                MediaView(mediaUrls: post.mediaUrls!),

              // Footer
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Text('     ${totalReaction == 0 ? '' : totalReaction}'),
                        const Spacer(),
                        Text('${totalComment == 0 ? '' : totalComment}     '),
                      ],
                    ),
                  ),
                  const Divider(height: 0, thickness: 0.2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        for (var type in ReactionType.values)
                            if (isLiked && selectedReaction != null && type == selectedReaction)
                              IconButton(
                                icon: Icon(
                                  _iconForReaction(type),
                                  color: switch (type) {
                                    ReactionType.LIKE => Colors.blue,
                                    ReactionType.LOVE => Colors.pink,
                                    ReactionType.ANGRY => Colors.orange,
                                    ReactionType.SAD => Colors.grey,
                                  },
                                ),
                                onPressed: () => toggleLike(type),
                                tooltip: type.toString().split('.').last,
                              )
                            else if (!isLiked)
                              IconButton(
                                icon: Icon(_iconForReaction(type)),
                                onPressed: () => toggleLike(type),
                                tooltip: type.toString().split('.').last,
                              ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.comment_outlined),
                          onPressed: commentPost,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void commentPost() async => CommentPost(
    context,
    post,
    currentUser,
    setState,
    _commentController,
    totalComment,
  );

  IconData _iconForReaction(ReactionType type) {
    switch (type) {
      case ReactionType.LIKE:
        return Icons.thumb_up;
      case ReactionType.LOVE:
        return Icons.favorite;
      case ReactionType.ANGRY:
        return Icons.sentiment_very_dissatisfied;
      case ReactionType.SAD:
        return Icons.sentiment_dissatisfied;
      }
  }
}
