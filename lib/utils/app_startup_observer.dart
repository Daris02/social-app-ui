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
    debugPrint('📞 [global] Update provider');
    if (provider == userProvider && newValue != null) {
      debugPrint('📞 [global] Update provider and confirm value');
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
    debugPrint('📞 [global] Init listening call request');

    void attachHandler() {
      if (socket.hasConnected) {
        debugPrint('📞 [global] socket connecté, handler attaché');
        socket.attachGlobalCallRequestHandler((data) {
          debugPrint('📞 [global] Call request venant du socket');
          final peerName = data['fromName'] ?? 'Inconnu';
          final peerId = data['from']?.toString();
          if (peerId == null) return;
          showIncomingCallNotification(peerName, peerId);
        });
      } else {
        debugPrint('📞 [global] socket pas encore connecté, attente...');
        Future.delayed(const Duration(milliseconds: 200), attachHandler);
      }
    }

    attachHandler();
  }
}
