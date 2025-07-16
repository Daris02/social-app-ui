import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';

Future<Uint8List?> getVideoThumbnail(String videoUrl) async {
  try {
    final thumbnail = await VideoThumbnail.thumbnailData(
      video: videoUrl,
      imageFormat: ImageFormat.PNG,
      maxWidth: 1280,
      quality: 75,
    );
    return thumbnail;
  } catch (e) {
    print("Thumbnail error: $e");
    return null;
  }
}
