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

  const PostItem({super.key, required this.post, required this.user});

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
                MediaView(post: post),

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
                        IconButton(
                          icon: Icon(
                            isLiked
                                ? Icons.thumb_up
                                : Icons.thumb_up_alt_outlined,
                            color: isLiked ? Colors.blue : null,
                          ),
                          onPressed: toggleLike,
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
}
