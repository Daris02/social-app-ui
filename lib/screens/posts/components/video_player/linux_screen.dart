import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:social_app/services/post_service.dart';

class VideoPlayerScreenLinux extends StatefulWidget {
  final String url;
  const VideoPlayerScreenLinux({super.key, required this.url});

  @override
  State<VideoPlayerScreenLinux> createState() => _VideoPlayerScreenLinuxState();
}

class _VideoPlayerScreenLinuxState extends State<VideoPlayerScreenLinux> {
  late final player = Player();
  late final controller = VideoController(player);

  @override
  void initState() {
    MediaKit.ensureInitialized();
    super.initState();
    player.open(Media(widget.url));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded),
            onPressed: () => PostService.downloadMedia(widget.url),
          ),
        ],
      ),
      body: Center(child: Video(controller: controller)),
    );
  }
}
