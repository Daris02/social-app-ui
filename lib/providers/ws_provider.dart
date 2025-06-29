import 'dart:async';
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
      _isConnected = true;
      print('[Socket.io] Connected');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      print('[Socket.io] Disconnected');
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

    _socket!.onAny((event, data) {
      print('[Socket.io] Event reçu: $event, data: $data');
      if (event == 'chat') {
        try {
          final msg = Message.fromJson(data);
          for (var listener in _messageListeners) {
            listener(msg);
          }
        } catch (e) {
          print('Erreur de parsing message: $e');
        }
      }
    });
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

  void sendMessage(int toUserId, String message) {
    send('chat', {'to': toUserId, 'content': message});
  }

  void send(String event, dynamic payload) {
    _socket?.emit(event, payload);
  }

  bool isConnected(int userId) {
    return _connectedUsers.contains(userId);
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
