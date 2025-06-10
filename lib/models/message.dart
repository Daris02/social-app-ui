class Message {
  final String content;
  final String author;

  Message({required this.content, required this.author});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(content: json['content'], author: json['author']);
  }

  Map<String, dynamic> toJson() {
    return {'content': content, 'author': author, 'type': 'chat'};
  }
}
