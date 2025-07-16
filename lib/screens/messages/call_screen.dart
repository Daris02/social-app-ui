import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:social_app/providers/ws_provider.dart';
import 'package:social_app/services/call_service.dart';

class VideoCallScreen extends ConsumerStatefulWidget {
  final VideoCallService callService;
  final bool isCaller;

  const VideoCallScreen({
    super.key,
    required this.callService,
    required this.isCaller,
  });

  @override
  ConsumerState<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends ConsumerState<VideoCallScreen> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();

  bool isMuted = false;
  bool isCameraOff = false;
  bool _hasRemoteVideo = false;
  bool _isRendererDisposed = false;

  late final WebSocketService socket;

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    socket = ref.read(webSocketServiceProvider);

    final service = widget.callService;
    service.attachRenderers(
      localRenderer: _localRenderer,
      remoteRenderer: _remoteRenderer,
      onRemoteTrackReady: () {
        if (!mounted || _isRendererDisposed) return;

        final hasVideo =
            _remoteRenderer.srcObject?.getVideoTracks().any((t) => t.enabled) ??
            false;

        debugPrint('[VideoCallScreen] Remote track ready ----');
        setState(() {
          _hasRemoteVideo = hasVideo;
        });
      },
    );

    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted &&
          !_isRendererDisposed &&
          _remoteRenderer.srcObject != null) {
        final hasVideo =
            _remoteRenderer.srcObject?.getVideoTracks().any((t) => t.enabled) ??
            false;

        if (hasVideo && !_hasRemoteVideo) {
          setState(() {
            _remoteRenderer.srcObject = widget.callService.currentRemoteStream;
            _hasRemoteVideo =
                _remoteRenderer.srcObject?.getVideoTracks().any(
                  (t) => t.enabled,
                ) ??
                false;
          });
        }
      }
    });
    socket.onCallEnded((_) async {
      if (!mounted) return;

      await widget.callService.hangUp(ref, notifyPeer: false);
      if (mounted) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          context.go('/');
        }
      }
    });
  }

  void _toggleMute() {
    setState(() {
      isMuted = !isMuted;
      widget.callService.toggleAudio(isMuted);
    });
  }

  void _toggleCamera() {
    setState(() {
      isCameraOff = !isCameraOff;
      widget.callService.toggleVideo(isCameraOff);
    });
  }

  void _hangUp() async {
    if (!mounted) return;
    await widget.callService.hangUp(ref, notifyPeer: true);

    if (!mounted) return;
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      context.go('/');
    }
  }

  @override
  void dispose() {
    _isRendererDisposed = true;
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;

    try {
      _localRenderer.dispose();
    } catch (e) {
      debugPrint("_localRenderer dispose failed: $e");
    }

    try {
      _remoteRenderer.dispose();
    } catch (e) {
      debugPrint("_remoteRenderer dispose failed: $e");
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      '🎬 isRemoteVideoDisplayed: $_hasRemoteVideo | srcObject=${_remoteRenderer.srcObject}',
    );
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote video ou fallback
          Positioned.fill(
            child: _hasRemoteVideo
                ? RTCVideoView(
                    _remoteRenderer,
                    objectFit:
                        RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                    mirror: false,
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.videocam_off, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'En attente de la vidéo distante...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
          ),

          // Local video
          if (_localRenderer.srcObject != null)
            Positioned(
              top: 32,
              right: 16,
              child: Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: RTCVideoView(_localRenderer, mirror: true),
              ),
            ),

          // Boutons de contrôle
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'mute',
                  backgroundColor: isMuted ? Colors.red : Colors.blue,
                  onPressed: _toggleMute,
                  child: Icon(isMuted ? Icons.mic_off : Icons.mic),
                ),
                FloatingActionButton(
                  heroTag: 'camera',
                  backgroundColor: isCameraOff ? Colors.red : Colors.blue,
                  onPressed: _toggleCamera,
                  child: Icon(
                    isCameraOff ? Icons.videocam_off : Icons.videocam,
                  ),
                ),
                FloatingActionButton(
                  heroTag: 'hangup',
                  backgroundColor: Colors.red,
                  onPressed: _hangUp,
                  child: const Icon(Icons.call_end),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
