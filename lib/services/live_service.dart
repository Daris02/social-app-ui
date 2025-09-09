import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/providers/ws_provider.dart';

final liveStreamServiceProvider = Provider.family<LiveStreamService, bool>((ref, isHost) {
  final socket = ref.watch(webSocketServiceProvider);
  final currentUser = ref.read(userProvider);
  return LiveStreamService(
    socket: socket,
    roomId: "live_room",
    selfUserId: currentUser!.id,
    isHost: isHost,
  );
});

class LiveStreamService {
  final WebSocketService socket;
  final String roomId;
  final int selfUserId;
  final bool isHost;

  RTCPeerConnection? _pc;
  MediaStream? _local;
  final ValueNotifier<MediaStream?> remoteStream = ValueNotifier(null);

  LiveStreamService({
    required this.socket,
    required this.roomId,
    required this.selfUserId,
    required this.isHost,
  });

  Future<void> initLocal({bool audio = true, bool video = true}) async {
    if (!isHost) return;
    _local = await navigator.mediaDevices.getUserMedia({'audio': audio, 'video': video});
  }

  MediaStream? get localStream => _local;

  Future<void> join() async {
    _bindSocket();
    socket.joinRoom(roomId);
  }

  Future<void> leave({bool notify = true}) async {
    if (notify) socket.leaveRoom(roomId);
    await _pc?.close();
    _pc = null;
    await _local?.dispose();
    _local = null;
    remoteStream.value = null;
    _unbindSocket();
  }

  void _bindSocket() {
    socket.onGroupOffer((data) async {
      if ((data['roomId'] as String) != roomId) return;
      if (isHost) return;

      final sdp = data['sdp'];
      _pc ??= await _createPeerConnection();

      await _pc!.setRemoteDescription(
        RTCSessionDescription(sdp['sdp'], sdp['type']),
      );
      final answer = await _pc!.createAnswer();
      await _pc!.setLocalDescription(answer);
      socket.sendGroupAnswer(roomId, data['fromUserId'], selfUserId, answer.toMap());
    });

    socket.onGroupAnswer((data) async {
      if ((data['roomId'] as String) != roomId) return;
      if (!isHost) return;

      final sdp = data['sdp'];
      await _pc?.setRemoteDescription(
        RTCSessionDescription(sdp['sdp'], sdp['type']),
      );
    });

    socket.onGroupCandidate((data) async {
      if ((data['roomId'] as String) != roomId) return;
      final c = data['candidate'];
      await _pc?.addCandidate(
        RTCIceCandidate(c['candidate'], c['sdpMid'], c['sdpMLineIndex']),
      );
    });
  }

  void _unbindSocket() {
    for (final evt in ['group_offer','group_answer','group_candidate']) {
      socket.off(evt);
    }
  }

  Future<void> startBroadcast() async {
    if (!isHost) return;
    _pc = await _createPeerConnection();
    for (var t in _local?.getTracks() ?? []) {
      await _pc!.addTrack(t, _local!);
    }
    final offer = await _pc!.createOffer({'offerToReceiveVideo': 0});
    await _pc!.setLocalDescription(offer);
    socket.sendGroupOffer(roomId, -1, selfUserId, offer.toMap());
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    final pc = await createPeerConnection({
      'iceServers': [
        {'urls': ['stun:stun.l.google.com:19302']},
      ]
    });

    if (!isHost) {
      pc.onTrack = (ev) {
        final stream = ev.streams.isNotEmpty ? ev.streams.first : null;
        remoteStream.value = stream;
      };
    }

    pc.onIceCandidate = (cand) {
      socket.sendGroupCandidate(roomId, -1, selfUserId, cand.toMap());
    };

    return pc;
  }
}
