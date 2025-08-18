import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:social_app/main.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/screens/messages/call_screen.dart';
import 'package:social_app/services/call_service.dart';

void showIncomingCallNotification(String partnerName, String partnerId) async {
  final content = NotificationContent(
    id: 1,
    channelKey: 'calls',
    title: 'Appel entrant',
    body: 'Appel vidéo de $partnerName',
    category: NotificationCategory.Call,
    wakeUpScreen: Platform.isAndroid,
    fullScreenIntent: Platform.isAndroid,
    payload: {
      'type': 'incoming_call',
      'peerId': partnerId,
      'peerName': partnerName,
    },
  );

  final actionButtons = [
    NotificationActionButton(
      key: 'ACCEPT',
      label: 'Accepter',
      color: const Color(0xFF4CAF50),
      autoDismissible: true,
    ),
    NotificationActionButton(
      key: 'DECLINE',
      label: 'Refuser',
      color: const Color(0xFFF44336),
      autoDismissible: true,
      isDangerousOption: true,
    ),
  ];

  await AwesomeNotifications().createNotification(
    content: content,
    actionButtons: actionButtons,
  );
}

@pragma('vm:entry-point')
Future<void> onActionReceivedMethod(ReceivedAction action) async {
  final payload = action.payload;
  final actionId = action.buttonKeyPressed;

  if (payload == null || !payload.containsKey('peerId')) {
    return;
  }

  final peerId = payload['peerId']!;

  final container = ProviderScope.containerOf(
    navigatorKey.currentContext!,
    listen: false,
  );
  final user = container.read(userProvider);
  final params = VideoCallParams(user!.id.toString(), peerId);
  final callService = container.read(videoCallServiceProvider(params));
  if (actionId == 'ACCEPT') {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) =>
            VideoCallScreen(callService: callService, isCaller: false),
      ),
    );
  } else if (actionId == 'DECLINE' || actionId.isEmpty) {
    AwesomeNotifications().cancel(1);
    callService.refuseCall();
  }
}

LocalNotification? _activeCallNotification;

void showDesktopIncomingCallNotification(String partnerName, String partnerId) {
  if (_activeCallNotification != null) {
    _activeCallNotification!.onClickAction = null;
    _activeCallNotification!.close();
    _activeCallNotification = null;
  }

  final notification = LocalNotification(
    identifier: 'incoming_call',
    title: 'Appel entrant',
    body: 'Appel vidéo de $partnerName',
    silent: false,
    actions: [
      LocalNotificationAction(text: 'Accepter', type: 'button'),
      LocalNotificationAction(text: 'Refuser', type: 'button'),
    ],
  );

  notification.onClickAction = (actionId) async {
    debugPrint('Action: $actionId | Partner ID: $partnerId');

    final container = ProviderScope.containerOf(
      navigatorKey.currentContext!,
      listen: false,
    );

    final user = container.read(userProvider);
    final params = VideoCallParams(user!.id.toString(), partnerId);
    final callService = container.read(videoCallServiceProvider(params));

    if (actionId == 0) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) =>
              VideoCallScreen(callService: callService, isCaller: false),
        ),
      );
    } else if (actionId == 1) {
      // Decline
      callService.refuseCall();
    }

    notification.onClickAction = null;
    notification.close();
    _activeCallNotification = null;
  };

  notification.show();
  _activeCallNotification = notification;
}
