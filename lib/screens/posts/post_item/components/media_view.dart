import 'package:flutter/material.dart';
import 'package:social_app/models/post.dart';
import 'package:social_app/screens/posts/post_item/components/image_view.dart';

import '../../video_player/video_player.dart';

class MediaView extends StatelessWidget {
  const MediaView({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: post.mediaUrls!.map((url) {
        final isImage =
            url.endsWith('.jpg') ||
            url.endsWith('.jpeg') ||
            url.endsWith('.png') ||
            url.endsWith('.gif');
        final isVideo =
            url.endsWith('.mp4') ||
            url.endsWith('.webm') ||
            url.endsWith('.mov');
    
        if (isImage) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ImageViewerScreen(url: url),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      url,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          height: 200,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            value:
                                progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded /
                                      progress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 100),
                    ),
                  ),
                ),
                // Positioned(
                //   top: 8,
                //   right: 8,
                //   child: IconButton(
                //     icon: const Icon(
                //       Icons.download,
                //       color: Colors.white,
                //     ),
                //     onPressed: () => PostService.downloadMedia(url),
                //   ),
                // ),
              ],
            ),
          );
        } else if (isVideo) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.black12,
                  child: const Center(
                    child: Icon(
                      Icons.videocam,
                      size: 60,
                      color: Colors.black45,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                VideoPlayerScreen(url: url),
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
            ),
          );
        } else {
          return const SizedBox();
        }
      }).toList(),
    );
  }
}
