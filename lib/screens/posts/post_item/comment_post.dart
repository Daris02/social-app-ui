import 'package:flutter/material.dart';
import 'package:social_app/services/post_service.dart';

Future<void> CommentPost(
  context,
  post,
  currentUser,
  setState,
  commentController,
  totalComment,
) {
  return showModalBottomSheet(
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
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                                              decoration: const InputDecoration(
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
                                                  final newContent = controller
                                                      .text
                                                      .trim();
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
                                        builder: (context) => AlertDialog(
                                          title: const Text(
                                            'Supprimer ce commentaire ?',
                                          ),
                                          content: const Text(
                                            'Cette action est irréversible.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Annuler'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
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
                                        Navigator.pop(context);
                                      }

                                      final comments =
                                          await PostService.getCommentsByPostId(
                                            post.id,
                                          );
                                      setState(() {
                                        post.comments = comments;
                                        totalComment = comments.length;
                                      });
                                      CommentPost(
                                        context,
                                        post,
                                        currentUser,
                                        setState,
                                        commentController,
                                        totalComment,
                                      );
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
              controller: commentController,
              decoration: InputDecoration(
                hintText: "Ajouter un commentaire...",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final content = commentController.text.trim();
                    if (content.isNotEmpty) {
                      await PostService.commentPost(
                        post.id,
                        currentUser.id,
                        content,
                      );
                      commentController.clear();

                      final comments = await PostService.getCommentsByPostId(
                        post.id,
                      );
                      setState(() {
                        post.comments = comments;
                        totalComment = comments.length;
                      });
                      Navigator.pop(context);
                      CommentPost(
                        context,
                        post,
                        currentUser,
                        setState,
                        commentController,
                        totalComment,
                      );
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
