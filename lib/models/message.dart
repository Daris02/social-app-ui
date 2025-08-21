enum MessageStatus { sending, sent, failed }

class Message {
  final int? id;
  final int? tempId;
  final int from;
  final int to;
  final String? content;
  final DateTime createdAt;
  final List<String>? mediaUrls;
  final String? mediaType;
  final MessageStatus status;

  Message({
    this.id,
    this.tempId,
    required this.from,
    required this.to,
    this.content,
    required this.createdAt,
    this.mediaUrls,
    this.mediaType,
    this.status = MessageStatus.sending,
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
      tempId: json['tempId'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      mediaUrls: mediaUrls,
      mediaType: json['mediaType'],
      status: MessageStatus.sent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'from': from,
      'to': to,
      'tempId': tempId,
      'createdAt': createdAt.toIso8601String(),
      'mediaUrls': mediaUrls,
      'mediaType': mediaType,
    };
  }

  Message copyWith({
    int? id,
    int? tempId,
    int? from,
    int? to,
    String? content,
    List<String>? mediaUrls,
    String? mediaType,
    DateTime? createdAt,
    MessageStatus? status,
  }) {
    return Message(
      id: id ?? this.id,
      tempId: tempId ?? this.tempId,
      from: from ?? this.from,
      to: to ?? this.to,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      mediaType: mediaType ?? this.mediaType,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}
