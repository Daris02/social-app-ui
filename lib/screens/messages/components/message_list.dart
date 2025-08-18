import 'package:flutter/material.dart';
import 'package:social_app/constant/api.dart';
import 'package:social_app/models/message.dart';
import 'package:social_app/utils/video_player.dart';

class MessageList extends StatelessWidget {
  final List<Message> messages;
  final int currentUserId;

  const MessageList({
    super.key,
    required this.messages,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      padding: EdgeInsets.all(8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        return buildMessageItem(message);
      },
    );
  }

  Widget buildMessageItem(Message message) {
    final isMe = message.from == currentUserId;
    final String baseUrl = DioClient.baseApiUrl.contains('http://')
        ? ''
        : DioClient.baseApiUrl;
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Card(
        color: isMe ? Colors.blue : Colors.grey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (message.content != null && message.content!.isNotEmpty)
                Text(message.content!),
              if (message.mediaUrls != null && message.mediaUrls!.isNotEmpty)
                ...message.mediaUrls!.map((url) {
                  if (message.mediaType == 'image') {
                    debugPrint('Image URL: $baseUrl$url');
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Image.network('$baseUrl$url', width: 400),
                    );
                  } else if (message.mediaType == 'video') {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: VideoPlayerScreen(
                          url: baseUrl + url,
                          autoPlay: false,
                        ),
                      ),
                    );
                  } else {
                    // Document ou autre
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: InkWell(
                        // onTap: () => launchUrl(Uri.parse(url)),
                        child: Row(
                          children: [
                            Icon(Icons.insert_drive_file),
                            SizedBox(width: 8),
                            Text('Document'),
                          ],
                        ),
                      ),
                    );
                  }
                }),
            ],
          ),
        ),
      ),
    );
  }
}
