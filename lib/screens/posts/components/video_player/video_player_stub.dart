import 'package:flutter/material.dart';

class VideoPlayerScreen extends StatelessWidget {
  final String url;
  const VideoPlayerScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Lecteur vidéo non supporté sur cette plateforme.'),
    );
  }
}
