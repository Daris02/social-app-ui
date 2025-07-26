import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';

void showIncomingCallNotification(String partnerName, String partnerId) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 1,
      channelKey: 'call_channel',
      title: 'Appel entrant',
      body: 'Appel vidéo de $partnerName',
      category: NotificationCategory.Call,
      wakeUpScreen: true,
      fullScreenIntent: true,
      payload: {
        'type': 'incoming_call',
        'peerId': partnerId,
        'peerName': partnerName,
      },
    ),
    actionButtons: [
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
    ],
  );
}
