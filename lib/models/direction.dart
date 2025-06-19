
class Direction {
  int id;
  String name;

  Direction({required this.id, required this.name});

  factory Direction.fromJson(Map<String, dynamic> json) {
    return Direction(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
