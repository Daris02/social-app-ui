import 'package:social_app/models/user.dart';

class Comment {
  final int id;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User user;

  Comment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      user: User.fromJson(json['user']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt'])
    );
  }
}
