import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:social_app/constant/api.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/theme/theme_provider.dart';
import 'package:social_app/utils/app_startup_observer.dart';
import 'package:social_app/utils/notification_call.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';
import 'routes/app_router.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await localNotifier.setup(
      appName: 'Social App',
      shortcutPolicy: ShortcutPolicy.requireCreate,
    );
  }
  
  await dotenv.load(fileName: ".env");
  DioClient.init();

  // Initialize Awesome Notifications
  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'calls',
      channelName: 'Calls',
      channelDescription: 'Channel for incoming video calls',
      importance: NotificationImportance.High,
      defaultColor: Colors.teal,
      ledColor: Colors.white,
      channelShowBadge: true,
      locked: true,
      criticalAlerts: true,
    ),
  ], debug: true);

  // Request permissions
  await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });

  // Listen to notification actions
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: onActionReceivedMethod,
  );

  VideoPlayerMediaKit.ensureInitialized(linux: true, windows: true);
  runApp(ProviderScope(observers: [AppStartupObserver()], child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final init = ref.watch(userInitProvider);
    final theme = ref.watch(themeProvider);

    return init.when(
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (err, data) {
        final appRouter = ref.watch(appRouterProvider);
        debugPrint('Data : $data');
        return MaterialApp.router(
          title: 'Flutter App Auth',
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          theme: theme,
        );
      },
      data: (_) {
        final appRouter = ref.watch(appRouterProvider);
        return MaterialApp.router(
          title: 'Flutter App Auth',
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          theme: theme,
        );
      },
    );
  }
}
