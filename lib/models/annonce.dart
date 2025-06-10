import 'package:social_app/models/user.dart';

class Annonce {
  final int id;
  final String title;
  final String content;
  final User author;

  Annonce({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
  });

  factory Annonce.fromJson(Map<String, dynamic> json) {
    return Annonce(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      author: User.fromJson(json['author']),
    );
  }
}
