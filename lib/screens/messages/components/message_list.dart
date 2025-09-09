import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:social_app/constant/api.dart';
import 'package:social_app/models/message.dart';
import 'package:social_app/utils/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';
import '../../../services/message_service.dart';
import './full_screen_gallery.dart';

class MessageList extends StatefulWidget {
  final List<Message> messages;
  final int currentUserId;

  const MessageList({
    super.key,
    required this.messages,
    required this.currentUserId,
  });

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(8),
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[widget.messages.length - 1 - index];
        return buildMessageItem(context, message);
      },
    );
  }

  Widget buildMessageItem(BuildContext context, Message message) {
    final isMe = message.from == widget.currentUserId;
    final String baseUrl = DioClient.baseApiUrl.contains('http://')
        ? DioClient.baseApiUrl
        : '';

    final bool isDesktop =
        Theme.of(context).platform == TargetPlatform.macOS ||
        Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.linux;

    // --- Widgets médias ---
    Widget mediaWidgets() {
      if (message.mediaUrls == null || message.mediaUrls!.isEmpty)
        return const SizedBox();
      return Wrap(
        spacing: 6,
        runSpacing: 6,
        children: message.mediaUrls!.map((url) {
          if (message.mediaType == 'image') {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullScreenGallery(
                      mediaUrls: message.mediaUrls!
                          .map((u) => '$baseUrl$url')
                          .toList(),
                      initialIndex: message.mediaUrls!.indexOf(url),
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: '$baseUrl$url',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            );
          } else if (message.mediaType == 'video') {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoPlayerScreen(url: baseUrl + url),
                  ),
                );
              },
              child: FutureBuilder<String?>(
                future: VideoThumbnail.thumbnailFile(
                  video: baseUrl + url,
                  imageFormat: ImageFormat.JPEG,
                  maxHeight: 80,
                  quality: 50,
                ),
                builder: (context, snapshot) {
                  Widget thumb;
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    thumb = Image.file(
                      File(snapshot.data!),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    );
                  } else {
                    thumb = Container(
                      width: 80,
                      height: 80,
                      color: Colors.black12,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: thumb,
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_circle_fill,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          } else {
            return Icon(
              HugeIcons.strokeRoundedFileAttachment,
              size: 50,
              color: Theme.of(context).colorScheme.inverseSurface,
            );
          }
        }).toList(),
      );
    }

    // --- Widget texte ---
    Widget textWidget() {
      if (message.content == null || message.content!.isEmpty)
        return const SizedBox();
      return Card(
        color: isMe ? Colors.blue[50] : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            message.content!,
            style: TextStyle(
              color: isMe ? Colors.blue[900] : Colors.black87,
              fontSize: 15,
            ),
          ),
        ),
      );
    }

    List<Widget> messageContent = [];
    if (message.content != null && message.content!.isNotEmpty)
      messageContent.add(textWidget());
    if (message.mediaUrls != null && message.mediaUrls!.isNotEmpty)
      messageContent.add(mediaWidgets());

    Widget wrappedCard = Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: messageContent,
    );

    if (isMe && message.status == MessageStatus.sent && message.id != null) {
      if (isDesktop) {
        wrappedCard = GestureDetector(
          onSecondaryTapDown: (details) async {
            final selected = await showMenu<String>(
              context: context,
              position: RelativeRect.fromRect(
                details.globalPosition & const Size(40, 40),
                Offset.zero & MediaQuery.of(context).size,
              ),
              items: [
                const PopupMenuItem(value: 'update', child: Text('Editer')),
                const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
              ],
            );

            if (selected == 'delete') {
              await MessageService.removeMessage(message.id!);
              setState(
                () => widget.messages.removeWhere((m) => m.id == message.id),
              );
            } else if (selected == 'update') {
              // TODO: Update message
            }
          },
          child: wrappedCard,
        );
      } else {
        wrappedCard = GestureDetector(
          onLongPress: () async {
            final selected = await showMenu<String>(
              context: context,
              position: RelativeRect.fromLTRB(100, 100, 100, 100),
              items: [
                const PopupMenuItem(value: 'update', child: Text('Edité')),
                const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
              ],
            );
            if (selected != null) _handleMenuAction(context, selected, message);
          },
          child: wrappedCard,
        );
      }
    }

    return Align(
      alignment: isMe ? Alignment.bottomRight : Alignment.bottomLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: isMe ? EdgeInsets.only(left: 75) : EdgeInsets.only(right: 75),
        child: wrappedCard,
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    String value,
    Message message,
  ) async {
    if (value == 'update') {
      // onUpdate!(message);
    } else if (value == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Supprimer le message ?'),
          content: const Text('Cette action est irréversible. Continuer ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: Theme.of(ctx).colorScheme.inversePrimary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'Supprimer',
                style: TextStyle(
                  color: Theme.of(ctx).colorScheme.inversePrimary,
                ),
              ),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await MessageService.removeMessage(message.id!);
        setState(() => widget.messages.removeWhere((m) => m.id == message.id));
      }
    }
  }
}
