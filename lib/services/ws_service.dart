import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebRTCSignaling {
  late final SharedPreferences prefs;
  late final String? token;

  late final int? userId;
  late final WebSocketChannel _ws;

  WebRTCSignaling._();

  static Future<WebRTCSignaling> create() async {
    final instance = WebRTCSignaling._();
    instance.prefs = await SharedPreferences.getInstance();
    instance.token = instance.prefs.getString('token');
    instance.userId = instance.prefs.getInt('id');
    instance._ws = WebSocketChannel.connect(
      Uri.parse('ws://192.168.0.53:4000?token=${instance.token}'),
    );
    // instance._ws = WebSocketChannel.connect(
    //   Uri.parse('ws://192.168.88.201?token=${instance.token}'),
    // );
    // instance._ws = WebSocketChannel.connect(
    //   Uri.parse('ws://192.168.112.12?token=${instance.token}'),
    // );
    return instance;
  }

  final _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  late RTCPeerConnection _peer;
  late MediaStream _localStream;
  MediaStream? remoteStream;
  Function(MediaStream stream)? onRemoteStream;
  final remoteStreamNotifier = ValueNotifier<MediaStream?>(null);

  String? targetId;
  Future<void> init() async {
    _localStream = await navigator.mediaDevices.getUserMedia({
      'video': true,
      'audio': true,
    });
    _peer = await createPeerConnection(_iceServers);

    // ✅ Ajoute chaque piste manuellement
    for (var track in _localStream.getTracks()) {
      _peer.addTrack(track, _localStream);
    }

    // 🎧 Gestion des flux distants
    _peer.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        remoteStream = event.streams[0];
        remoteStreamNotifier.value = remoteStream;
        onRemoteStream?.call(remoteStream!);
      }
    };

    _peer.onIceCandidate = (candidate) {
      if (targetId != null) {
        _send('candidate', targetId!, candidate.toMap());
      }
    };

    _ws.stream.listen((data) async {
      final msg = jsonDecode(data);
      print('[WS] Message $msg');

      switch (msg['type']) {
        case 'offer':
          targetId = msg['from'];
          await _peer.setRemoteDescription(
            RTCSessionDescription(msg['data']['sdp'], msg['data']['type']),
          );
          final answer = await _peer.createAnswer();
          await _peer.setLocalDescription(answer);
          _send('answer', msg['from'], answer.toMap());
          break;
        case 'answer':
          await _peer.setRemoteDescription(
            RTCSessionDescription(msg['data']['sdp'], msg['data']['type']),
          );
          break;
        case 'candidate':
          await _peer.addCandidate(
            RTCIceCandidate(
              msg['data']['candidate'],
              msg['data']['sdpMid'],
              msg['data']['sdpMLineIndex'],
            ),
          );
          break;
      }
    });
  }

  void _send(String type, String to, dynamic data) {
    _ws.sink.add(
      jsonEncode({'type': type, 'from': userId.toString(), 'to': to, 'data': data}),
    );
  }

  MediaStream getLocalStream() => _localStream;

  Future<void> call(String peerId) async {
    targetId = peerId;
    final offer = await _peer.createOffer();
    await _peer.setLocalDescription(offer);
    _send('offer', peerId, offer.toMap());
  }

  void dispose() {
    _peer.close();
    _localStream.dispose();
    _ws.sink.close();
  }
}
