import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/providers/ws_provider.dart';
import 'package:social_app/utils/notification_call.dart';

final class AppStartupObserver extends ProviderObserver {
  bool _isListeningToCalls = false;
  StreamSubscription<bool>? _connectionSub;

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    if (context.provider == userProvider && newValue != null && !_isListeningToCalls) {
      _isListeningToCalls = true;
      final user = newValue as User;
      final socket = context.container.read(webSocketServiceProvider);

      _listenToIncomingCalls(context.container, socket, user);
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
