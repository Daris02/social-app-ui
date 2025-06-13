import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:social_app/services/ws_service.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});
  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  WebRTCSignaling? _signaling;
  final _remoteRenderer = RTCVideoRenderer();
  final _localRenderer = RTCVideoRenderer();
  final _peerIdController = TextEditingController();
  bool _isMicEnabled = true;

  @override
  void initState() {
    super.initState();
    _initSignalingAndRenderers();
  }

  Future<void> _initSignalingAndRenderers() async {
    final signaling = await WebRTCSignaling.create();
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    await signaling.init();

    setState(() {
      _signaling = signaling;
      _localRenderer.srcObject = signaling.getLocalStream();
    });

    _localRenderer.srcObject = signaling.getLocalStream();

    final stream = signaling.getLocalStream();
    setState(() {
      _localRenderer.srcObject = stream;
    });

    signaling.remoteStreamNotifier.addListener(() {
      final stream = signaling.remoteStreamNotifier.value;

      if (stream != null) {
        setState(() {
          _remoteRenderer.srcObject = stream;
        });
      }
    });
  }

  void _toggleMic() {
    final audioTrack = _signaling?.getLocalStream().getAudioTracks().first;
    if (audioTrack != null) {
      setState(() {
        _isMicEnabled = !_isMicEnabled;
        audioTrack.enabled = _isMicEnabled;
      });
    }
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _signaling?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_signaling == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appel vidéo"),
        actions: [
          IconButton(
            icon: Icon(_isMicEnabled ? Icons.mic : Icons.mic_off),
            onPressed: _toggleMic,
            tooltip: _isMicEnabled ? 'Couper le micro' : 'Activer le micro',
          ),
        ],
      ),
      body: Column(
        children: [
          Text(
            "My ID: ${_signaling?.userId}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Expanded(
            child: RTCVideoView(
              _remoteRenderer,
              filterQuality: FilterQuality.high,
              mirror: true,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
            ),
          ),
          Expanded(
            child: RTCVideoView(
              _localRenderer,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
              mirror: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _peerIdController,
                    decoration: const InputDecoration(
                      hintText: 'Peer ID distant',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final id = _peerIdController.text.trim();
                    if (id.isNotEmpty) _signaling?.call(id);
                  },
                  child: const Text("Appeler"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
