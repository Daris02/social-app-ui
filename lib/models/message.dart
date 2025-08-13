class Message {
  final int? id;
  final int? from;
  final int? to;
  final String? content;
  final DateTime createdAt;
  final List<String>? mediaUrls;
  final String? mediaType;
  final bool isLocal;

  Message({
    this.id,
    this.content,
    this.from,
    this.to,
    required this.createdAt,
    this.mediaUrls,
    this.mediaType,
    this.isLocal = false,
  });

  factory Message.fromJson(Map<dynamic, dynamic> json) {
    final mediaUrls = (json['mediaUrls'] as List<dynamic>?)
        ?.map((url) => url.toString())
        .toList();
    return Message(
      id: json['id'],
      content: json['content'],
      from: json['from'],
      to: json['to'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      mediaUrls: json['mediaUrls'] != null ? mediaUrls : null,
      mediaType: json['mediaType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'from': from,
      'to': to,
      'createdAt': createdAt.toIso8601String(),
      'mediaUrls': mediaUrls?.join(','),
      'mediaType': mediaType,
    };
  }
}
