import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/material.dart';
import 'package:social_app/providers/ws_provider.dart';

class GroupCallRoomService {
  final WebSocketService socket;
  final String roomId;
  final int selfUserId;

  final Map<int, RTCPeerConnection> _pc = {};
  final Map<int, MediaStream> _remote = {};

  MediaStream? _local;
  final ValueNotifier<Map<int, MediaStream>> remoteStreams = ValueNotifier({});

  GroupCallRoomService({
    required this.socket,
    required this.roomId,
    required this.selfUserId,
  });

  Future<void> initLocal({bool audio = true, bool video = true}) async {
    _local = await navigator.mediaDevices.getUserMedia({'audio': audio, 'video': video});
  }

  MediaStream? get localStream => _local;

  Future<void> join() async {
    _bindSocket();
    socket.joinRoom(roomId);
  }

  Future<void> leave({bool notify = true}) async {
    if (notify) socket.leaveRoom(roomId);
    await _closeAll();
    _unbindSocket();
    await _local?.dispose();
    _local = null;
  }

  void _bindSocket() {
    socket.onRoomUsers((rid, users) async {
      if (rid != roomId) return;
      // le nouveau initie un offer vers chacun
      for (final u in users) {
        await _ensurePeer(u);
        await _createAndSendOffer(u);
      }
    });

    socket.onRoomUserJoined((rid, newUser) async {
      if (rid != roomId || newUser == selfUserId) return;
      // le nouvel arrivant va nous envoyer une offer; on attend
    });

    socket.onRoomUserLeft((rid, uid) async {
      if (rid != roomId) return;
      await _removePeer(uid);
    });

    socket.onGroupOffer((data) async {
      if ((data['roomId'] as String) != roomId) return;
      final from = data['fromUserId'] as int;
      final sdp = data['sdp'];
      final pc = await _ensurePeer(from);
      await pc.setRemoteDescription(RTCSessionDescription(sdp['sdp'], sdp['type']));
      final answer = await pc.createAnswer();
      await pc.setLocalDescription(answer);
      socket.sendGroupAnswer(roomId, from, selfUserId, answer.toMap());
    });

    socket.onGroupAnswer((data) async {
      if ((data['roomId'] as String) != roomId) return;
      final from = data['fromUserId'] as int;
      final sdp = data['sdp'];
      final pc = _pc[from];
      if (pc == null) return;
      await pc.setRemoteDescription(RTCSessionDescription(sdp['sdp'], sdp['type']));
    });

    socket.onGroupCandidate((data) async {
      if ((data['roomId'] as String) != roomId) return;
      final from = data['fromUserId'] as int;
      final c = data['candidate'];
      final pc = _pc[from];
      if (pc == null) return;
      await pc.addCandidate(RTCIceCandidate(c['candidate'], c['sdpMid'], c['sdpMLineIndex']));
    });

    socket.onGroupEnded((rid, by) async {
      if (rid != roomId) return;
      await leave(notify: false);
    });
  }

  void _unbindSocket() {
    for (final evt in [
      'room_users','room_user_joined','room_user_left',
      'group_offer','group_answer','group_candidate','group_ended'
    ]) {
      socket.off(evt);
    }
  }

  Future<RTCPeerConnection> _ensurePeer(int otherUserId) async {
    if (_pc.containsKey(otherUserId)) return _pc[otherUserId]!;
    final pc = await createPeerConnection({
      // En LAN tu peux laisser vide; hors LAN ajoute STUN/TURN ici
      'iceServers': [{'urls': 'stun:stun.l.google.com:19302'}],
    });

    if (_local != null) {
      for (final t in _local!.getTracks()) {
        await pc.addTrack(t, _local!);
      }
    }

    pc.onTrack = (ev) async {
      final stream = ev.streams.isNotEmpty
          ? ev.streams.first
          : (await createLocalMediaStream('remote-$otherUserId')..addTrack(ev.track));
      _remote[otherUserId] = stream;
      remoteStreams.value = Map.of(_remote);
    };

    pc.onIceCandidate = (cand) {
      socket.sendGroupCandidate(roomId, otherUserId, selfUserId, cand.toMap());
    };

    _pc[otherUserId] = pc;
    return pc;
  }

  Future<void> _createAndSendOffer(int toUserId) async {
    final pc = _pc[toUserId]!;
    final offer = await pc.createOffer({'iceRestart': false});
    await pc.setLocalDescription(offer);
    socket.sendGroupOffer(roomId, toUserId, selfUserId, offer.toMap());
  }

  Future<void> _removePeer(int userId) async {
    try { await _pc[userId]?.close(); } catch (_) {}
    _pc.remove(userId);

    try { await _remote[userId]?.dispose(); } catch (_) {}
    _remote.remove(userId);
    remoteStreams.value = Map.of(_remote);
  }

  Future<void> _closeAll() async {
    for (final p in _pc.values) { try { await p.close(); } catch (_) {} }
    _pc.clear();
    for (final s in _remote.values) { try { await s.dispose(); } catch (_) {} }
    _remote.clear();
    remoteStreams.value = {};
  }

  // contrôles locaux
  void toggleMic(bool mute) => _local?.getAudioTracks().forEach((t) => t.enabled = !mute);
  void toggleCamera(bool off) => _local?.getVideoTracks().forEach((t) => t.enabled = !off);
}
