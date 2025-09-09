import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:social_app/screens/posts/post_item/components/media_gallery_screen.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../../utils/video_player.dart';

class MediaView extends StatefulWidget {
  final List<String> mediaUrls;
  const MediaView({super.key, required this.mediaUrls});

  @override
  State<MediaView> createState() => _MediaViewState();
}

class _MediaViewState extends State<MediaView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final mediaUrls = widget.mediaUrls;
    if (mediaUrls.isEmpty) return const SizedBox();

    Widget buildMedia(int index, {bool expanded = false}) {
      final url = mediaUrls[index];
      final isImage =
          url.endsWith('.jpg') ||
          url.endsWith('.jpeg') ||
          url.endsWith('.png') ||
          url.endsWith('.gif');
      final isVideo =
          url.endsWith('.mp4') || url.endsWith('.webm') || url.endsWith('.mov');

      if (isImage) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MediaGalleryScreen(
                  mediaUrls: widget.mediaUrls,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(expanded ? 0 : 14),
            child: CachedNetworkImage(
              imageUrl: url,
              height: expanded ? MediaQuery.of(context).size.height : 260,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image, size: 100),
            ),
          ),
        );
      } else if (isVideo) {
        if (expanded) {
          // Ouvre directement le player en mode fullscreen
          Future.microtask(() {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => VideoPlayerScreen(url: url)),
            );
          });
          return const SizedBox();
        }
        return FutureBuilder<String?>(
          future: VideoThumbnail.thumbnailFile(
            video: url,
            imageFormat: ImageFormat.JPEG,
            maxHeight: 260,
            quality: 75,
          ),
          builder: (context, snapshot) {
            Widget thumb;
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              thumb = Image.file(
                File(snapshot.data!),
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
              );
            } else {
              thumb = Container(
                height: 260,
                width: double.infinity,
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: thumb,
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VideoPlayerScreen(url: url),
                          ),
                        );
                      },
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_fill,
                          size: 64,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        // Document ou autre type
        return Container(
          height: expanded ? MediaQuery.of(context).size.height : 260,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(expanded ? 0 : 14),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.insert_drive_file,
                  size: 60,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                Text(
                  url.split('/').last,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }
    }

    return Stack(
      children: [
        SizedBox(
          height: 260,
          width: double.infinity,
          child: PageView.builder(
            itemCount: mediaUrls.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) => buildMedia(index),
          ),
        ),
        if (mediaUrls.length > 1)
          Positioned(
            bottom: 12,
            right: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentIndex + 1}/${mediaUrls.length}',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
      ],
    );
  }
}
