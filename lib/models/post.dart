import 'package:social_app/models/comment.dart';
import 'package:social_app/models/reaction.dart';
import 'package:social_app/models/user.dart';

class Post {
  final int id;
  final String title;
  final String content;
  final User author;
  final DateTime createdAt;
  final List<String>? mediaUrls;
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
    this.mediaUrls,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    List<Reaction> reactions = [];
    List<Comment> comments = [];
    final mediaUrls = (json['mediaUrls'] as List<dynamic>?)
        ?.map((url) => url.toString())
        .toList();
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      mediaUrls: mediaUrls,
      author: User.fromJson(json['author']),
      reactions: reactions,
      comments: comments,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
