import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:social_app/providers/ws_provider.dart';

final videoCallServiceProvider =
    Provider.family<VideoCallService, VideoCallParams>((ref, params) {
      final socket = ref.read(webSocketServiceProvider);
      return VideoCallService(
        socket: socket,
        userId: params.userId,
        peerId: params.peerId,
      );
    });

class VideoCallParams {
  final String userId;
  final String peerId;

  VideoCallParams(this.userId, this.peerId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoCallParams &&
          runtimeType == other.runtimeType &&
          ((userId == other.userId && peerId == other.peerId) ||
              (userId == other.peerId && peerId == other.userId));

  @override
  int get hashCode => userId.hashCode ^ peerId.hashCode;
}

class VideoCallService {
  final WebSocketService socket;
  final String userId;
  final String peerId;

  RTCPeerConnection? _peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;

  bool _isConnected = false;
  bool _isCaller = false;

  Function(MediaStream)? _onLocalStream;
  Function(MediaStream)? _onRemoteStream;
  Function()? onCallRequest;
  Function()? onCallAccepted;
  Function()? onCallRefused;

  set onLocalStream(Function(MediaStream)? handler) {
    _onLocalStream = handler;
    if (handler != null && localStream != null) {
      handler(localStream!);
    }
  }

  set onRemoteStream(Function(MediaStream)? handler) {
    _onRemoteStream = handler;
    if (handler != null && remoteStream != null) {
      handler(remoteStream!);
    }
  }

  VideoCallService({
    required this.socket,
    required this.userId,
    required this.peerId,
  });

  Future<void> connect(bool isCaller) async {
    if (_isConnected) return;
    _isConnected = true;
    _isCaller = isCaller;

    _bindSocketEvents();
  }

  Completer<void>? _preparingCompleter;
  MediaStream? get currentRemoteStream => remoteStream;
  MediaStream? get currentLocalStream => localStream;

  void attachRenderers({
    required RTCVideoRenderer localRenderer,
    required RTCVideoRenderer remoteRenderer,
    VoidCallback? onRemoteTrackReady,
  }) {
    if (localStream != null) {
      localRenderer.srcObject = localStream;
    }
    if (remoteStream != null) {
      remoteRenderer.srcObject = remoteStream;
      onRemoteTrackReady?.call();
    }

    _onLocalStream = (s) => localRenderer.srcObject = s;
    _onRemoteStream = (s) {
      remoteRenderer.srcObject = s;
      onRemoteTrackReady?.call();
    };
  }

  Future<void> get readyFuture {
    if (_preparingCompleter == null) {
      return _prepareConnection();
    }
    return _preparingCompleter!.future;
  }

  Future<void> _prepareConnection() async {
    if (_preparingCompleter != null) return _preparingCompleter!.future;
    _preparingCompleter = Completer();

    try {
      if (_peerConnection != null) return;

      localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': true,
      });
      _onLocalStream?.call(localStream!);

      _peerConnection = await createPeerConnection({
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ]
      });
      for (final track in localStream!.getTracks()) {
        _peerConnection!.addTrack(track, localStream!);
      }
      _peerConnection!.onTrack = (event) {
        if (event.streams.isNotEmpty) {
          remoteStream = event.streams.first;
          if (_onRemoteStream != null) {
            _onRemoteStream!.call(remoteStream!);
          }
        }
      };

      _peerConnection!.onIceCandidate = (candidate) {
        socket.sendCandidate(peerId, candidate.toMap());
      };
      _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
        debugPrint('Connection state: $state');
      };
      _peerConnection!.onIceConnectionState = (state) {
        debugPrint('ICE connection state: $state');
      };

      _preparingCompleter?.complete();
    } catch (e) {
      _preparingCompleter?.completeError(e);
      rethrow;
    }
  }

  void _bindSocketEvents() {
    socket.onOffer((data) async {
      final sdp = data['offer'] ?? data['data'];
      final offer = RTCSessionDescription(sdp['sdp'], sdp['type']);

      try {
        await _prepareConnection();
        if (_peerConnection == null) {
          return;
        }
        await _peerConnection!.setRemoteDescription(offer);
        if (_peerConnection == null) {
          return;
        }

        try {
          final answer = await _peerConnection!.createAnswer();
          await _peerConnection!.setLocalDescription(answer);
          socket.sendAnswer(userId, peerId, answer.toMap());
        } catch (e) {
          debugPrint('Failed to create or set answer: $e');
        }
      } catch (e) {
        debugPrint('Erreur lors de la réception de l’offre : $e');
      }
    });

    socket.onAnswer((data) async {
      if (!_isCaller) {
        debugPrint("[callee] doit ignorer answer");
        return;
      }
      if (_isCaller) {
        debugPrint("[caller] recoit answer");
      }
      final sdp = data['answer'] ?? data['data'];
      final answer = RTCSessionDescription(sdp['sdp'], sdp['type']);
      await _peerConnection?.setRemoteDescription(answer);
    });

    socket.onCandidate((data) async {
      final c = data['candidate'] ?? data['data'];
      final candidate = RTCIceCandidate(
        c['candidate'],
        c['sdpMid'],
        c['sdpMLineIndex'],
      );
      debugPrint('Remote ICE Candidate: ${candidate.candidate}');

      try {
        final state = _peerConnection!.signalingState;
        if (state != RTCSignalingState.RTCSignalingStateStable &&
            state != RTCSignalingState.RTCSignalingStateHaveRemoteOffer &&
            state != RTCSignalingState.RTCSignalingStateHaveLocalPrAnswer) {
          debugPrint('RTCSignalingState = $state)');
          return;
        } else {
          await _peerConnection!.addCandidate(candidate);
        }
      } catch (e) {
        debugPrint('Erreur lors de addCandidate: $e');
      }
    });

    socket.onCallAccepted((data) async {
      if (_isCaller) {
        await _prepareConnection();
        final offer = await _peerConnection!.createOffer();
        await _peerConnection!.setLocalDescription(offer);
        socket.sendOffer(peerId, offer.toMap());
      }

      onCallAccepted?.call();
    });

    socket.onCallRefused((data) {
      onCallRefused?.call();
    });
  }

  Future<void> startCall() async {
    final ids = [userId, peerId]..sort();
    final roomId = ids.join('-');
    socket.sendCallRequest(userId, peerId, roomId);
  }

  Future<void> acceptCall() async {
    final ids = [userId, peerId]..sort();
    final roomId = ids.join('-');
    await _prepareConnection();
    socket.sendCallAccepted(userId, peerId, roomId);
  }

  Future<void> refuseCall() async {
    final ids = [userId, peerId]..sort();
    final roomId = ids.join('-');
    socket.sendCallRefused(userId, peerId, roomId);
  }

  void toggleAudio(bool mute) {
    localStream?.getAudioTracks().forEach((track) {
      track.enabled = !mute;
    });
  }

  void toggleVideo(bool cameraOff) {
    localStream?.getVideoTracks().forEach((track) {
      track.enabled = !cameraOff;
    });
  }

  void _unbindSocketEvents() {
    socket.clearHandlersForEvents([
      'offer',
      'answer',
      'candidate',
      'call_accepted',
      'call_refused',
      'call_ended',
    ]);
  }

  Future<void> hangUp(WidgetRef ref, {bool notifyPeer = true}) async {
    if (notifyPeer) {
      final ids = [userId, peerId]..sort();
      final roomId = ids.join('-');
      socket.sendCallEnded(userId, peerId, roomId);
    }

    await dispose();
    ref.invalidate(videoCallServiceProvider(VideoCallParams(userId, peerId)));
  }

  bool _isDisposed = false;

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    try {
      if (_peerConnection != null) {
        await _peerConnection!.close();
        _peerConnection = null;
      }
    } catch (e) {
      debugPrint('Error closing peerConnection: $e');
    }

    try {
      await localStream?.dispose();
    } catch (e) {
      debugPrint('Error disposing localStream: $e');
    }
    localStream = null;

    try {
      await remoteStream?.dispose();
    } catch (e) {
      debugPrint('Error disposing remoteStream: $e');
    }
    remoteStream = null;

    _unbindSocketEvents();

    _onLocalStream = null;
    _onRemoteStream = null;
    onCallRequest = null;
    onCallAccepted = null;
    onCallRefused = null;

    _isConnected = false;
    _isCaller = false;
    _preparingCompleter = null;
  }
}
