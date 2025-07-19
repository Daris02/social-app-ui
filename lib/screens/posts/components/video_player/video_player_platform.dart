import 'dart:io';


import 'screen.dart';
import 'linux_screen.dart';
import 'package:flutter/widgets.dart';

class VideoPlayerScreen extends StatelessWidget {
  final String url;
  const VideoPlayerScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    if (Platform.isLinux) {
      return VideoPlayerScreenLinux(url: url);
    } else {
      return VideoPlayerScreenDefault(videoUrl: url);
    }
  }
}
