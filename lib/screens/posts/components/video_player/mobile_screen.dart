import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:social_app/services/post_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String url;
  final bool autoPlay;
  final bool looping;

  const VideoPlayerScreen({
    super.key,
    required this.url,
    this.autoPlay = true,
    this.looping = false,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoController;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    await _videoController.initialize();
    _videoController.setLooping(widget.looping);

    if (widget.autoPlay) {
      await _videoController.play();
      _isPlaying = true;
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }

    _videoController.addListener(() {
      if (mounted) {
        setState(() {
          _isPlaying = _videoController.value.isPlaying;
        });
      }
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_videoController.value.isPlaying) {
      _videoController.pause();
    } else {
      _videoController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () => PostService.downloadMedia(widget.url),
          ),
        ],
      ),
      body: Center(
        child: !_isInitialized
            ? const CircularProgressIndicator()
            : Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio,
                    child: VideoPlayer(_videoController),
                  ),
                  GestureDetector(
                    onTap: _togglePlayPause,
                    child: AnimatedOpacity(
                      opacity: _isPlaying ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: const Icon(
                        Icons.play_circle_fill,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
