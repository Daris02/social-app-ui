import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/providers/ws_provider.dart';
import 'package:social_app/utils/notification_call.dart';

class AppStartupObserver extends ProviderObserver {
  bool _isListeningToCalls = false;
  StreamSubscription<bool>? _connectionSub;

  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (provider == userProvider && newValue != null && !_isListeningToCalls) {
      _isListeningToCalls = true;
      final user = newValue as User;
      final socket = container.read(webSocketServiceProvider);

      _listenToIncomingCalls(container, socket, user);
    }
  }

  void _listenToIncomingCalls(
    ProviderContainer container,
    WebSocketService socket,
    User user,
  ) {
    _connectionSub = socket.connectionStream.listen((connected) {
      if (connected) {
        socket.attachGlobalCallRequestHandler((data) {
          final peerName = data['fromName'] ?? 'Inconnu';
          final peerId = data['from']?.toString();
          if (peerId == null) return;
          if (Platform.isAndroid || Platform.isIOS) {
            showIncomingCallNotification(peerName, peerId);
          } else {
            showDesktopIncomingCallNotification(peerName, peerId);
          }
        });
        _connectionSub?.cancel();
      }
    });
  }
}
