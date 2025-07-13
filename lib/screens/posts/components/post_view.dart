import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:social_app/models/enums/reaction_type.dart';
import 'package:social_app/models/post.dart';
import 'package:social_app/models/user.dart';
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
  late final Post post;
  late User author;
  late final User currentUser;
  int totalReaction = 0;
  int totalComment = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    post = widget.post;
    author = post.author;
    currentUser = widget.user;

    fetchData();
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
    setState(() {});
  }

  Future<void> toggleLike() async {
    if (!isLiked) {
      await PostService.likePost(post.id, currentUser.id, ReactionType.LIKE);
      setState(() {
        totalReaction++;
        isLiked = true;
      });
    } else {
      await PostService.unlikePost(post.id, currentUser.id);
      setState(() {
        totalReaction--;
        isLiked = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final dateStr = DateFormat('dd MMM yyyy à HH:mm').format(post.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            leading: CircleAvatar(
              backgroundImage: author.photo != null
                  ? NetworkImage(author.photo!)
                  : null,
              child: author.photo == null ? const Icon(Icons.person) : null,
            ),
            title: Text("${author.firstName} ${author.lastName}"),
            subtitle: Text(dateStr),
          ),
          // Media
          if (post.imagesUrl != null && post.imagesUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post.imagesUrl![0],
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
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
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



//           // Image ou titre
//           if (widget.post.imagesUrl != null &&
//               widget.post.imagesUrl!.isNotEmpty)
//             ClipRRect(
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(18),
//               ),
//               child: Image.network(
//                 widget.post.imagesUrl![0],
//                 height: 180,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//               ),
//             )
//           else if (widget.post.title.isNotEmpty)
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     const Color.fromARGB(255, 122, 123, 125),
//                     const Color.fromARGB(255, 8, 118, 207),
//                   ],
//                   begin: Alignment.centerLeft,
//                   end: Alignment.centerRight,
//                 ),
//                 borderRadius: const BorderRadius.vertical(
//                   top: Radius.circular(18),
//                 ),
//               ),
//               child: Center(
//                 child: Text(
//                   widget.post.title,
//                   style: const TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                     shadows: [
//                       Shadow(
//                         blurRadius: 8,
//                         color: Colors.black26,
//                         offset: Offset(1, 2),
//                       ),
//                     ],
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//           // Contenu
//           if (widget.post.content.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(
//                 widget.post.content,
//                 style: const TextStyle(fontSize: 16),
//               ),
//             ),