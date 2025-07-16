import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:social_app/main.dart';

void showIncomingCallNotification(String partnerName, String partnerId) async {
  final androidDetails = AndroidNotificationDetails(
    'call_channel',
    'Appels vidéo',
    channelDescription: 'Notification d’appel vidéo',
    importance: Importance.max,
    priority: Priority.high,
    // timeoutAfter: 10_000,
    actions: [
      AndroidNotificationAction('ACCEPT', 'Accepter'),
      AndroidNotificationAction('DECLINE', 'Refuser'),
    ],
  );

  final linuxDetails = LinuxNotificationDetails(
    timeout: LinuxNotificationTimeout(5000),
    urgency: LinuxNotificationUrgency.critical,
    icon: AssetsLinuxIcon('icons/logo-senat.png'),
    actions: <LinuxNotificationAction>[
      LinuxNotificationAction(key: 'ACCEPT', label: 'Accepter'),
      LinuxNotificationAction(key: 'DECLINE', label: 'Refuser'),
    ],
  );

  final windowsDetails = WindowsNotificationDetails();

  final notificationDetails = NotificationDetails(
    android: androidDetails,
    linux: linuxDetails,
    windows: windowsDetails,
  );

  await localNotificationsPlugin.show(
    1,
    'Appel entrant',
    'Appel vidéo de $partnerName',
    notificationDetails,
    payload: 'incoming_call|$partnerId|$partnerName',
  );
}
