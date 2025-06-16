import 'package:social_app/models/user.dart';

class Post {
  final int id;
  final String title;
  final String content;
  final User author;
  final DateTime createdAt;
  final List<String>? imagesUrl;
  final int reactions;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdAt,
    required this.reactions,
    this.imagesUrl,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    List<dynamic> reactions = [];
    if (json['reactions'] != null) {
      reactions = json['reactions'];
    }
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      author: User.fromJson(json['author']),
      reactions: reactions.length,
      createdAt: DateTime.parse(json['createdAt'])
    );
  }
}
