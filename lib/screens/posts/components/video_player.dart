import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:social_app/services/post_service.dart';

class CachedChewiePlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool looping;

  const CachedChewiePlayer({
    super.key,
    required this.videoUrl,
    this.autoPlay = true,
    this.looping = false,
  });

  @override
  State<CachedChewiePlayer> createState() => _CachedChewiePlayerState();
}

class _CachedChewiePlayerState extends State<CachedChewiePlayer> {
  late CachedVideoPlayerPlus _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = CachedVideoPlayerPlus.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController.controller,
      autoPlay: widget.autoPlay,
      looping: widget.looping,
      allowFullScreen: false,
      allowPlaybackSpeedChanging: true,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(errorMessage, style: TextStyle(color: Colors.white)),
        );
      },
    );

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController.dispose();
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
            icon: const Icon(Icons.download_rounded),
            onPressed: () => PostService.downloadMedia(widget.videoUrl),
          ),
        ],
      ),
      body: (_chewieController == null || !_videoPlayerController.isInitialized)
          ? const Center(child: CircularProgressIndicator())
          : Expanded(child: Chewie(controller: _chewieController!)),
    );
  }
}
