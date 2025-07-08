class Message {
  final int? id;
  final int from;
  final int to;
  final String content;
  final DateTime createdAt;

  Message({
    this.id,
    required this.content,
    required this.from,
    required this.to,
    required this.createdAt,
  });

  factory Message.fromJson(Map<dynamic, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      from: json['from'],
      to: json['to'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'from': from,
      'type': 'chat',
      'to': to,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
