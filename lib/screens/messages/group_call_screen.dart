import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:social_app/services/group_call_service.dart';

class GroupCallScreen extends StatefulWidget {
  final GroupCallRoomService service;
  const GroupCallScreen({super.key, required this.service});

  @override
  State<GroupCallScreen> createState() => _GroupCallScreenState();
}

class _GroupCallScreenState extends State<GroupCallScreen> {
  final _localRenderer = RTCVideoRenderer();
  bool _micMuted = true;
  bool _camOff = true;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    await _localRenderer.initialize();
    await widget.service.initLocal(audio: true, video: true);
    if (widget.service.localStream != null) {
      _localRenderer.srcObject = widget.service.localStream;
    }
    await widget.service.join();
  }

  @override
  void dispose() {
    _localRenderer.srcObject = null;
    _localRenderer.dispose();
    widget.service.leave(); // cleanup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: const Text('Group Call'),
        title: Text(widget.service.roomId),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ValueListenableBuilder<Map<int, MediaStream>>(
            valueListenable: widget.service.remoteStreams,
            builder: (_, remote, __) {
              final entries = remote.entries.toList();
              if (entries.isEmpty) {
                return const Center(
                  child: Text(
                    'En attente de participants…',
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // simple
                  childAspectRatio: 9 / 16,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: entries.length,
                itemBuilder: (_, i) {
                  final stream = entries[i].value;
                  return _RemoteTile(stream: stream);
                },
              );
            },
          ),

          if (_localRenderer.srcObject != null)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                width: 120,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: RTCVideoView(_localRenderer, mirror: true),
                ),
              ),
            ),

          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'mic',
                  backgroundColor: _micMuted ? Colors.red : Colors.blue,
                  onPressed: () {
                    setState(() => _micMuted = !_micMuted);
                    widget.service.toggleMic(_micMuted);
                  },
                  child: Icon(_micMuted ? Icons.mic_off : Icons.mic),
                ),
                FloatingActionButton(
                  heroTag: 'cam',
                  backgroundColor: _camOff ? Colors.red : Colors.blue,
                  onPressed: () {
                    setState(() => _camOff = !_camOff);
                    widget.service.toggleCamera(_camOff);
                  },
                  child: Icon(_camOff ? Icons.videocam_off : Icons.videocam),
                ),
                FloatingActionButton(
                  heroTag: 'leave',
                  backgroundColor: Colors.red,
                  onPressed: () async {
                    await widget.service.leave();
                    if (mounted) Navigator.pop(context);
                  },
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

class _RemoteTile extends StatefulWidget {
  final MediaStream stream;
  const _RemoteTile({required this.stream});

  @override
  State<_RemoteTile> createState() => _RemoteTileState();
}

class _RemoteTileState extends State<_RemoteTile> {
  final _renderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    await _renderer.initialize();
    _renderer.srcObject = widget.stream;
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant _RemoteTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stream.id != widget.stream.id) {
      _renderer.srcObject = widget.stream;
    }
  }

  @override
  void dispose() {
    _renderer.srcObject = null;
    _renderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: RTCVideoView(
      _renderer,
      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
    ),
  );
}
