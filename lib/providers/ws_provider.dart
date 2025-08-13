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

  bool get hasConnected => _isConnected;
  Stream<Set<int>> get connectedUsersStream => _streamController.stream;

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
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      _connectedUsers.clear();
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

  void attachGlobalCallRequestHandler(void Function(dynamic data) callback) {
    if (_isCallRequestHandlerAttached) {
      debugPrint('📞 Handler déjà attaché');
      return;
    }

    debugPrint('📞 [WebSocketService] Attaching global call_request handler');
    _socket?.on('call_request', callback);
    _isCallRequestHandlerAttached = true;
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
