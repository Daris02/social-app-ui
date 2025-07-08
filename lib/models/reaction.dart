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
}
