import 'dart:io';

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
  bool _micMuted = false;
  bool _camOff = false;

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
    setState(() {
      _camOff = true;
      widget.service.toggleCamera(_camOff);
      _micMuted = true;
      widget.service.toggleMic(_micMuted);
    });
  }

  @override
  void dispose() {
    _localRenderer.srcObject = null;
    _localRenderer.dispose();
    widget.service.leave();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Group Call - ${widget.service.roomId.split('-')[1]}'),
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
                itemCount: entries.length + 1,
                itemBuilder: (_, i) {
                  final stream = entries[i].value;
                  if (i == 0) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: RTCVideoView(
                        _localRenderer,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                      ),
                    );
                  }
                  return _RemoteTile(stream: stream);
                },
              );
            },
          ),

          // if (_localRenderer.srcObject != null)
          //   Positioned(
          //     top: 16,
          //     right: 16,
          //     child: Container(
          //       width: 120,
          //       height: 160,
          //       decoration: BoxDecoration(
          //         color: Colors.black,
          //         border: Border.all(color: Colors.white24),
          //         borderRadius: BorderRadius.circular(12),
          //       ),
          //       child: ClipRRect(
          //         borderRadius: BorderRadius.circular(12),
          //         child: RTCVideoView(_localRenderer, mirror: true),
          //       ),
          //     ),
          //   ),

          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 40,
              children: [
                _buildControlButton(
                  icon: _micMuted ? Icons.mic_off : Icons.mic,
                  color: _micMuted ? Colors.red : Colors.white,
                  onTap: () {
                    setState(() => _micMuted = !_micMuted);
                    widget.service.toggleMic(_micMuted);
                  },
                ),
                _buildControlButton(
                  icon: _camOff ? Icons.videocam_off : Icons.videocam,
                  color: _camOff ? Colors.red : Colors.white,
                  onTap: () {
                    setState(() => _camOff = !_camOff);
                    widget.service.toggleCamera(_camOff);
                  },
                ),
                if (Platform.isAndroid || Platform.isIOS) ...[
                  _buildControlButton(
                    icon: Icons.flip_camera_ios,
                    color: Colors.white,
                    onTap: () {}, //_switchCamera,
                  ),
                ],
                _buildControlButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  onTap: () async {
                    await widget.service.leave();
                    if (mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
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
