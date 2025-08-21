import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:social_app/services/post_service.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String url;
  final bool autoPlay;
  final bool looping;
  final bool appBar;

  const VideoPlayerScreen({
    super.key,
    required this.url,
    this.autoPlay = true,
    this.looping = false,
    this.appBar = true,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final CachedVideoPlayerPlus _player;
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  bool _isControllerReady = false;

  @override
  void initState() {
    super.initState();
    _player = CachedVideoPlayerPlus.networkUrl(
      Uri.parse(widget.url),
      invalidateCacheIfOlderThan: const Duration(days: 7),
    );
    _player.initialize().then((_) {
      setState(() {
        _controller = _player.controller;
        _controller!.setLooping(widget.looping);
        if (widget.autoPlay) {
          _controller!.play();
        }
        _chewieController = ChewieController(
          videoPlayerController: _controller!,
          autoPlay: widget.autoPlay,
          looping: widget.looping,
          aspectRatio: _controller!.value.aspectRatio,
          errorBuilder: (context, errorMessage) => Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          customControls: const CupertinoControls(
            backgroundColor: Colors.black87,
            iconColor: Colors.white,
          ),
          allowFullScreen: true,
          pauseOnBackgroundTap: true,
          additionalOptions: (context) => [
            OptionItem(
              onTap: (context) => PostService.downloadMedia(widget.url),
              iconData: Icons.download_rounded,
              title: 'Télécharger',
            ),
          ],
        );
        _isControllerReady = true;
      });
    });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isControllerReady ||
        _chewieController == null ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: widget.appBar
          ? AppBar(backgroundColor: Colors.transparent, elevation: 0)
          : null,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Chewie(controller: _chewieController!),
        ),
      ),
    );
  }
}
