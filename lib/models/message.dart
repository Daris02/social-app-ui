class Message {
  final int from;
  final int to;
  final String content;
  final DateTime createdAt;

  Message({
    required this.content,
    required this.from,
    required this.to,
    required this.createdAt,
  });

  factory Message.fromJson(Map<dynamic, dynamic> json) {
    return Message(
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
      'content': content,
      'from': from,
      'type': 'chat',
      'to': to,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
