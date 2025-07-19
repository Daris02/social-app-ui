import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/providers/ws_provider.dart';
import 'package:social_app/utils/notification_call.dart';

class AppStartupObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    if (provider == userProvider && newValue != null) {
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
    void attachHandler() {
      if (socket.hasConnected) {
        socket.attachGlobalCallRequestHandler((data) {
          final peerName = data['fromName'] ?? 'Inconnu';
          final peerId = data['from']?.toString();
          if (peerId == null) return;
          showIncomingCallNotification(peerName, peerId);
        });
      } else {
        Future.delayed(const Duration(milliseconds: 1000), attachHandler);
      }
    }

    attachHandler();
  }
}
