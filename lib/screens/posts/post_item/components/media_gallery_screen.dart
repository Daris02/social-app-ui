import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../utils/video_player.dart';

class MediaGalleryScreen extends StatefulWidget {
  final List<String> mediaUrls;
  final int initialIndex;
  const MediaGalleryScreen({
    super.key,
    required this.mediaUrls,
    required this.initialIndex,
  });

  @override
  State<MediaGalleryScreen> createState() => _MediaGalleryScreenState();
}

class _MediaGalleryScreenState extends State<MediaGalleryScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final mediaUrls = widget.mediaUrls;

    Widget buildMedia(int index) {
      final url = mediaUrls[index];
      final isImage = url.endsWith('.jpg') ||
          url.endsWith('.jpeg') ||
          url.endsWith('.png') ||
          url.endsWith('.gif');
      final isVideo = url.endsWith('.mp4') ||
          url.endsWith('.webm') ||
          url.endsWith('.mov');

      if (isImage) {
        return InteractiveViewer(
          child: Center(
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image, size: 100, color: Colors.white),
            ),
          ),
        );
      } else if (isVideo) {
        return VideoPlayerScreen(appBar: false, url: url,);
      } else {
        // Document ou autre type
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.insert_drive_file, size: 80, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                url.split('/').last,
                style: const TextStyle(fontSize: 16, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: mediaUrls.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) => buildMedia(index),
          ),
          if (mediaUrls.length > 1)
            Positioned(
              bottom: 24,
              right: 28,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentIndex + 1}/${mediaUrls.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
        ],
      ),
    );
  }
}