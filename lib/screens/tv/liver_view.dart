import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/services/live_service.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

final selectedSourceProvider = StateProvider<StreamSource?>((ref) => null);
final playlistProvider = StateProvider<List<File>>((ref) => []);

enum StreamSourceType { camera, video }

class StreamSource {
  final StreamSourceType type;
  final String label;

  StreamSource(this.type, this.label);
}

class LiverView extends ConsumerStatefulWidget {
  const LiverView({Key? key}) : super(key: key);

  @override
  ConsumerState createState() => _LiverViewState();
}

class _LiverViewState extends ConsumerState<LiverView> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  VideoPlayerController? _videoController;
  int _currentIndex = 0;
  LiveStreamService? _service;

  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _service = ref.read(liveStreamServiceProvider(true));
      await _service!.join();
    });
  }

  Future<void> _startCamera() async {
    final stream = await navigator.mediaDevices.getUserMedia({
      'video': {'facingMode': 'user'},
      'audio': true,
    });
    _localRenderer.srcObject = stream;
  }

  Future<void> _playVideoAt(int index) async {
    final playlist = ref.read(playlistProvider);
    if (index >= playlist.length) return;

    final file = playlist[index];
    _videoController?.dispose();
    _videoController = VideoPlayerController.file(file);

    await _videoController!.initialize();
    await _videoController!.play();

     // ⚡️ Capture le flux de la vidéo et le push au service
    final stream = await _videoController!.videoPlayerOptions?.mixWithOthers;
    // TODO: ici, tu devrais encoder la vidéo dans un `MediaStream`
    // Pour l’instant on reste en mock avec la caméra (car flutter_webrtc ne capture pas VideoPlayer directement)
    // --> tu pourrais encoder via `canvas`/`ffmpeg` pour le vrai flux.

    _videoController!.addListener(() async {
      if (_videoController!.value.position >= _videoController!.value.duration) {
        _currentIndex++;
        if (_currentIndex < playlist.length) {
          _playVideoAt(_currentIndex);
        }
      }
    });

    setState(() {});
  }

  void _switchSource(StreamSource source) {
    ref.read(selectedSourceProvider.notifier).state = source;
    if (source.type == StreamSourceType.camera) {
      _startCamera();
    } else if (source.type == StreamSourceType.video) {
      if (ref.read(playlistProvider).isNotEmpty) {
        _currentIndex = 0;
        _playVideoAt(_currentIndex);
      }
    }
  }

  Future<void> _addToPlaylist() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null) return;

    final picked = File(result.files.single.path!);
    final appDir = await getTemporaryDirectory();
    final newFile = await picked.copy(
      '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4',
    );

    ref.read(playlistProvider.notifier).update((state) => [...state, newFile]);

    if (_videoController == null || !_videoController!.value.isPlaying) {
      _currentIndex = 0;
      await _playVideoAt(_currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedSource = ref.watch(selectedSourceProvider);
    final playlist = ref.watch(playlistProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Player
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child:
                selectedSource?.type == StreamSourceType.video &&
                    _videoController != null &&
                    _videoController!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  )
                : RTCVideoView(_localRenderer, mirror: true),
          ),
        ),

        // Playlist + contrôle
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12)],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            children: [
              Wrap(
                spacing: 10,
                children: [
                  ChoiceChip(
                    label: const Text("Caméra"),
                    selected: selectedSource?.type == StreamSourceType.camera,
                    onSelected: (_) => _switchSource(
                      StreamSource(StreamSourceType.camera, "Caméra"),
                    ),
                  ),
                  ChoiceChip(
                    label: const Text("Vidéo"),
                    selected: selectedSource?.type == StreamSourceType.video,
                    onSelected: (_) => _switchSource(
                      StreamSource(StreamSourceType.video, "Vidéo"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _addToPlaylist,
                icon: const Icon(Icons.playlist_add),
                label: const Text("Programmer une vidéo"),
              ),
              if (playlist.isNotEmpty)
                Column(
                  children: playlist
                      .asMap()
                      .entries
                      .map(
                        (entry) => ListTile(
                          leading: Icon(
                            entry.key == _currentIndex
                                ? Icons.play_arrow
                                : Icons.movie,
                          ),
                          title: Text(
                            entry.value.path.split("/").last,
                            style: TextStyle(color: colorScheme.inversePrimary),
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _videoController?.dispose();
    _service?.leave();
    super.dispose();
  }
}
