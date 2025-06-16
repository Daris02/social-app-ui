import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:social_app/models/post.dart';
import 'package:social_app/providers/post_provider.dart';
import 'package:social_app/services/api_service.dart';

import '../models/user.dart';

class PostComponent extends ConsumerStatefulWidget {
  final Post post;
  final User author;

  const PostComponent({super.key, required this.post, required this.author});

  @override
  ConsumerState<PostComponent> createState() => _PostComponentState();
}

class _PostComponentState extends ConsumerState<PostComponent> {
  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy à HH:mm').format(widget.post.createdAt);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: widget.author.photo != null
                      ? NetworkImage(widget.author.photo!)
                      : null,
                  child: widget.author.photo == null
                      ? Text(
                          widget.author.firstName[0].toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.author.firstName} ${widget.author.lastName}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (dateStr.isNotEmpty)
                        Text(
                          dateStr,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () async {
                    // await ApiService.deletePost(widget.post.id);
                    // ref.refresh(postsProvider);
                  },
                ),
              ],
            ),
          ),
          // Image ou titre
          if (widget.post.imagesUrl != null && widget.post.imagesUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: Image.network(
                widget.post.imagesUrl![0],
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else if (widget.post.title.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 114, 115, 117),
                    const Color.fromARGB(255, 8, 118, 207),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
              ),
              child: Center(
                child: Text(
                  widget.post.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 8,
                        color: Colors.black26,
                        offset: Offset(1, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          // Contenu
          if (widget.post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(widget.post.content, style: const TextStyle(fontSize: 16)),
            ),
          // Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up_alt_outlined),
                  onPressed: () async {
                    await ApiService.likePost(widget.post.id, 'LIKE');
                    ref.refresh(postsProvider);
                    setState(() {
                      
                    });
                  },
                ),
                Text('${widget.post.reactions == 0 ? '' : widget.post.reactions}'),
                const SizedBox(width: 8),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
                Text('Commenter'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
