import 'package:social_app/models/user.dart';

class Post {
  final int id;
  final String title;
  final String content;
  final User author;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      author: User.fromJson(json['author']),
    );
  }
}
