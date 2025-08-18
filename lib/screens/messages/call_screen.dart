import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:go_router/go_router.dart';
import 'package:social_app/providers/ws_provider.dart';
import 'package:social_app/services/call_service.dart';

// ignore: must_be_immutable
class VideoCallScreen extends ConsumerStatefulWidget {
  final VideoCallService callService;
  final bool isCaller;
  bool isDesktopApp;

  VideoCallScreen({
    super.key,
    required this.callService,
    required this.isCaller,
    this.isDesktopApp = false,
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

  bool _showControls = true;
  late final WebSocketService socket;

  @override
  void initState() {
    super.initState();
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    if (!widget.isCaller) {
      await widget.callService.connect(false);
      await widget.callService.readyFuture;
      await widget.callService.acceptCall();
    }
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

        setState(() => _hasRemoteVideo = hasVideo);
      },
    );

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

  // void _switchCamera() {
  //   widget.callService.switchCamera();
  // }

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

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  @override
  void dispose() {
    _isRendererDisposed = true;
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Remote video or placeholder
            Positioned.fill(
              child: _hasRemoteVideo
                  ? RTCVideoView(
                      _remoteRenderer,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                      mirror: false,
                    )
                  : const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.videocam_off,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'En attente de la vidéo distante...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
            ),

            // Local video preview
            if (_localRenderer.srcObject != null)
              Positioned(
                top: 32,
                right: 16,
                child: GestureDetector(
                  onTap: () {}, //_switchCamera,
                  child: Container(
                    width: 120,
                    height: 160,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: RTCVideoView(_localRenderer, mirror: true),
                    ),
                  ),
                ),
              ),

            // Floating Bottom Navigation Controls
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: SafeArea(
                child: AnimatedOpacity(
                  opacity: _showControls ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildControlButton(
                            icon: isMuted ? Icons.mic_off : Icons.mic,
                            color: isMuted ? Colors.red : Colors.white,
                            onTap: _toggleMute,
                          ),
                          const SizedBox(width: 16),
                          _buildControlButton(
                            icon: isCameraOff
                                ? Icons.videocam_off
                                : Icons.videocam,
                            color: isCameraOff ? Colors.red : Colors.white,
                            onTap: _toggleCamera,
                          ),
                          if (Platform.isAndroid || Platform.isIOS) ...[
                            const SizedBox(width: 16),
                            _buildControlButton(
                              icon: Icons.flip_camera_ios,
                              color: Colors.white,
                              onTap: () {}, //_switchCamera,
                            ),
                          ],
                          const SizedBox(width: 16),
                          _buildControlButton(
                            icon: Icons.call_end,
                            color: Colors.red,
                            onTap: _hangUp,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        backgroundColor: Colors.black26,
        radius: 28,
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
