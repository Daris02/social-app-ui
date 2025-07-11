import 'package:social_app/models/enums/reaction_type.dart';
import 'package:social_app/models/user.dart';

class Reaction {
  final int id;
  final ReactionType reactionType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User user;

  Reaction({
    required this.id,
    required this.reactionType,
    required this.createdAt,
    required this.updatedAt,
    required this.user,
  });

  factory Reaction.fromJson(Map<String, dynamic> json) {
    return Reaction(
      id: json['id'],
      reactionType: reactionTypeFromString(json['reactionType'])!,
      user: User.fromJson(json['user']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  static ReactionType? reactionTypeFromString(String? value) {
    if (value == null) return null;
    return ReactionType.values.firstWhere((e) => e.name == value);
  }
}
