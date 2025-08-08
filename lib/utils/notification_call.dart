import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:social_app/main.dart';

import 'incoming_call_screen.dart';

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

  final actionButtons = Platform.isAndroid
      ? [
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
        ]
      : null;

  await AwesomeNotifications().createNotification(
    content: content,
    actionButtons: actionButtons,
  );
}

void showInAppIncomingCallScreen(String peerName, String peerId) {
  navigatorKey.currentState?.push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black54,
      pageBuilder: (_, __, ___) => InAppIncomingCallScreen(
        peerName: peerName,
        peerId: peerId,
      ),
    ),
  );
}
