
import 'package:social_app/models/comment.dart';
import 'package:social_app/models/reaction.dart';
import 'package:social_app/models/user.dart';

class Post {
  final int id;
  final String title;
  final String content;
  final User author;
  final DateTime createdAt;
  final List<String>? imagesUrl;
  List<Comment> comments;
  List<Reaction> reactions;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.comments,
    required this.reactions,
    this.imagesUrl,
  });

  // set comments(List<Comment> newComments) {
  //   comments = newComments;
  // }

  // set reactions(List<Reaction> newReactions) {
  //   reactions = newReactions;
  // }

  factory Post.fromJson(Map<String, dynamic> json) {
    List<Reaction> reactions = [];
    List<Comment> comments = [];
    // if (json['reactions'] != null) {
    //   for (var reaction in json['reactions']) {
    //     reactions.add(reaction);
    //   }
    // }
    // if (json['comments'] != null) {
    //   for (var comment in json['comments']) {
    //     comments.add(comment);
    //   }
    // }
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      author: User.fromJson(json['author']),
      reactions: reactions,
      comments: comments,
      createdAt: DateTime.parse(json['createdAt'])
    );
  }
}
