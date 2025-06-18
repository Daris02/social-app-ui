import 'package:hive/hive.dart';

part 'direction.g.dart';

@HiveType(typeId: 1)
class Direction extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  Direction({required this.id, required this.name});

  factory Direction.fromJson(Map<String, dynamic> json) {
    return Direction(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
