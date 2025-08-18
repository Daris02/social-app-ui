import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/constant/api.dart';
import 'package:social_app/models/message.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  ref.onDispose(() => service.dispose());
  ref.keepAlive();
  return service;
});

class WebSocketService {
  IO.Socket? _socket;
  bool _isConnected = false;
  final List<void Function(Message)> _messageListeners = [];
  final _connectedUsers = <int>{};
  final _streamController = StreamController<Set<int>>.broadcast();
  final _connectionStream = StreamController<bool>.broadcast();

  bool get hasConnected => _isConnected;
  Stream<Set<int>> get connectedUsersStream => _streamController.stream;
  Stream<bool> get connectionStream => _connectionStream.stream;

  void connect(String token) {
    if (_isConnected) {
      return;
    }

    _socket = IO.io(
      DioClient.baseSocket,
      IO.OptionBuilder().setTransports(['websocket']).setQuery({
        'token': token,
      }).build(),
    );

    _socket!.onConnect((_) {
      _isConnected = _socket!.connected;
      _connectionStream.add(true);
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      _connectedUsers.clear();
      _connectionStream.add(false);
      _streamController.add(_connectedUsers);
    });

    _socket!.on('connected_users', (data) {
      if (data is List) {
        _connectedUsers
          ..clear()
          ..addAll(data.whereType<int>());
        _streamController.add(_connectedUsers);
      }
    });

    _socket!.on('user_connected', (data) {
      if (data is Map && data['userId'] != null) {
        _connectedUsers.add(data['userId']);
        _streamController.add(_connectedUsers);
      }
    });

    _socket!.on('user_disconnected', (data) {
      if (data is Map && data['userId'] != null) {
        _connectedUsers.remove(data['userId']);
        _streamController.add(_connectedUsers);
      }
    });

    _socket!.onAny((event, data) async {
      switch (event) {
        case 'chat':
          try {
            final msg = Message.fromJson(data);
            for (var listener in _messageListeners) {
              listener(msg);
            }
          } catch (e) {
            debugPrint('Erreur de parsing message: $e');
          }
          break;
        default:
      }
    });
  }

  void send(String event, dynamic payload) {
    _socket?.emit(event, payload);
  }

  StreamSubscription<Message> onMessage(void Function(Message) callback) {
    final controller = StreamController<Message>();
    void listener(Message msg) {
      controller.add(msg);
    }

    _messageListeners.add(listener);

    final subscription = controller.stream.listen(callback);
    subscription.onDone(() {
      _messageListeners.remove(listener);
      controller.close();
    });

    return subscription;
  }

  void sendMessage(Message message) {
    send('chat', {'to': message.to, 'message': message});
  }

  void onChatUpdate(void Function(dynamic data) callback) {
    _socket?.on('chat_update', callback);
  }

  bool isConnected(int userId) {
    return _connectedUsers.contains(userId);
  }

  void sendPostUpdate(String userId, int postId) {
    send('post_updated', postId);
  }

  void onPostUpdated(void Function(int postId) callback) {
    _socket?.on('post_updated', (data) {
      final postId = data is Map && data['postId'] is int
          ? data['postId']
          : null;
      if (postId != null) callback(postId);
    });
  }

  void sendCallRequest(String userId, String toUserId, String roomId) {
    send('call_request', {'to': toUserId, 'from': userId, 'roomId': roomId});
  }

  void sendCallAccepted(String userId, String toUserId, String roomId) {
    send('call_accepted', {'to': toUserId, 'from': userId, 'roomId': roomId});
  }

  void sendCallRefused(String userId, String toUserId, String roomId) {
    send('call_refused', {'to': toUserId, 'from': userId, 'roomId': roomId});
  }

  void sendCallEnded(String userId, String toUserId, String roomId) {
    send('call_ended', {'from': userId, 'to': toUserId, 'roomId': roomId});
  }

  void onCallRequest(void Function(dynamic data) callback) {
    _socket?.on('call_request', callback);
    debugPrint('Call Request Coming ...');
  }

  bool _isCallRequestHandlerAttached = false;

  bool attachGlobalCallRequestHandler(void Function(dynamic data) callback) {
    if (_isCallRequestHandlerAttached) {
      return true;
    } else {
      _socket?.off('call_request');
      _socket?.on('call_request', callback);
      _isCallRequestHandlerAttached = true;
      return _isCallRequestHandlerAttached;
    }
  }

  void onCallAccepted(void Function(dynamic data) callback) {
    _socket?.on('call_accepted', callback);
  }

  void onCallRefused(void Function(dynamic data) callback) {
    _socket?.on('call_refused', callback);
  }

  void onCallEnded(void Function(dynamic data) callback) {
    _socket?.on('call_ended', callback);
  }

  void sendOffer(String toUserId, dynamic offer) {
    send('offer', {'to': toUserId, 'offer': offer});
  }

  void sendAnswer(String userId, String toUserId, dynamic answer) {
    send('answer', {
      'type': 'answer',
      'to': toUserId,
      'from': userId,
      'data': answer,
    });
  }

  void sendCandidate(String toUserId, dynamic candidate) {
    send('candidate', {'to': toUserId, 'candidate': candidate});
  }

  void onOffer(void Function(dynamic data) callback) {
    _socket?.on('offer', callback);
  }

  void onAnswer(void Function(dynamic data) callback) {
    _socket?.on('answer', callback);
  }

  void onCandidate(void Function(dynamic data) callback) {
    _socket?.on('candidate', callback);
  }

  void clearHandlersForEvents(List<String> eventNames) {
    for (final event in eventNames) {
      off(event);
    }
  }

  void off(String event) {
    _socket?.off(event);
  }

  void joinRoom(String roomId) => send('room_join', {'roomId': roomId});
  void leaveRoom(String roomId) => send('room_leave', {'roomId': roomId});

  void onRoomUsers(void Function(String roomId, List<int> userIds) cb) {
    _socket?.on('room_users', (data) {
      final roomId = data['roomId'] as String;
      final users =
          (data['users'] as List?)?.whereType<int>().toList() ?? <int>[];
      cb(roomId, users);
    });
  }

  void onRoomUserJoined(void Function(String roomId, int userId) cb) {
    _socket?.on('room_user_joined', (data) {
      cb(data['roomId'] as String, data['userId'] as int);
    });
  }

  void onRoomUserLeft(void Function(String roomId, int userId) cb) {
    _socket?.on('room_user_left', (data) {
      cb(data['roomId'] as String, data['userId'] as int);
    });
  }

  // ---- Signaling multi (évite l'interférence avec 1-1) ----
  void sendGroupOffer(
    String roomId,
    int toUserId,
    int fromUserId,
    dynamic sdp,
  ) {
    send('group_offer', {
      'roomId': roomId,
      'toUserId': toUserId,
      'fromUserId': fromUserId,
      'sdp': sdp,
    });
  }

  void sendGroupAnswer(
    String roomId,
    int toUserId,
    int fromUserId,
    dynamic sdp,
  ) {
    send('group_answer', {
      'roomId': roomId,
      'toUserId': toUserId,
      'fromUserId': fromUserId,
      'sdp': sdp,
    });
  }

  void sendGroupCandidate(
    String roomId,
    int toUserId,
    int fromUserId,
    dynamic candidate,
  ) {
    send('group_candidate', {
      'roomId': roomId,
      'toUserId': toUserId,
      'fromUserId': fromUserId,
      'candidate': candidate,
    });
  }

  void onGroupOffer(void Function(dynamic data) cb) =>
      _socket?.on('group_offer', cb);
  void onGroupAnswer(void Function(dynamic data) cb) =>
      _socket?.on('group_answer', cb);
  void onGroupCandidate(void Function(dynamic data) cb) =>
      _socket?.on('group_candidate', cb);

  void endGroup(String roomId, int byUserId) {
    send('group_end', {'roomId': roomId, 'by': byUserId});
  }

  void onGroupEnded(void Function(String roomId, int by) cb) {
    _socket?.on(
      'group_ended',
      (data) => cb(data['roomId'] as String, data['by'] as int),
    );
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
    _connectedUsers.clear();
    _streamController.add(_connectedUsers);
  }

  void dispose() {
    disconnect();
    _streamController.close();
  }
}
