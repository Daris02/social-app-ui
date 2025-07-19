import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/constant/api.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/screens/messages/call_screen.dart';
import 'package:social_app/services/call_service.dart';
import 'package:social_app/utils/app_startup_observer.dart';
import 'routes/app_router.dart';
import 'package:social_app/theme/dark_mode.dart';
import 'package:social_app/theme/light_mode.dart';

final FlutterLocalNotificationsPlugin localNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
void onNotificationResponse(NotificationResponse response) async {
  debugPrint('🔔 Notification action: ${response.actionId}');
  debugPrint('🔔 Notification payload: ${response.payload}');
  final payload = response.payload;
  if (payload == null || !payload.startsWith('incoming_call|')) return;

  final parts = payload.split('|');
  if (parts.length < 3) return;

  final peerId = parts[1];
  final peerName = parts[2];
  final action = response.actionId;

  final container = ProviderScope.containerOf(
    navigatorKey.currentContext!,
    listen: false,
  );
  final user = container.read(userProvider);
  final params = VideoCallParams(user!.id.toString(), peerId);
  final callService = container.read(videoCallServiceProvider(params));

  if (action == 'ACCEPT' || action == null) {
    await callService.connect(false);
    await callService.readyFuture;
    await callService.acceptCall();

    await localNotificationsPlugin.cancel(1);

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) =>
            VideoCallScreen(callService: callService, isCaller: false),
      ),
    );
  } else if (action == 'DECLINE') {
    await localNotificationsPlugin.cancel(1);
    callService.refuseCall();
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  DioClient.init();

  final initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    linux: LinuxInitializationSettings(
      defaultActionName: 'Ouvrir',
      defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
    ),
    windows: WindowsInitializationSettings(
      appName: 'Social App',
      appUserModelId: '',
      guid: '',
    ),
  );

  await localNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: onNotificationResponse,
    onDidReceiveBackgroundNotificationResponse: onNotificationResponse,
  );
  runApp(ProviderScope(observers: [AppStartupObserver()], child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final init = ref.watch(userInitProvider);

    return init.when(
      loading: () => MaterialApp(
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (err, data) {
        final appRouter = ref.watch(appRouterProvider);
        debugPrint('Data : $data');
        return MaterialApp.router(
          title: 'Flutter App Auth',
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          theme: lightMode,
          darkTheme: darkMode,
        );
      },
      data: (_) {
        final appRouter = ref.watch(appRouterProvider);
        return MaterialApp.router(
          title: 'Flutter App Auth',
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          theme: lightMode,
          darkTheme: darkMode,
        );
      },
    );
  }
}
