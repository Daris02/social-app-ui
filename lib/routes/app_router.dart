import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/screens/home.dart';
import 'package:social_app/screens/auth/login.dart';
import 'package:social_app/screens/auth/register.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/screens/messages/message.dart';
import 'package:social_app/screens/posts/post.dart';
import 'package:social_app/screens/setting.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    refreshListenable: GoRouterRefreshStream(
      ref.watch(userProvider.notifier).stream,
    ),
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomeScreen(),
        redirect: (context, state) {
          final user = ref.read(userProvider);
          if (user == null) return '/login';
          return null;
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(),
        redirect: (context, state) {
          final user = ref.read(userProvider);
          if (user != null) return '/';
          return null;
        },
      ),
      GoRoute(path: '/posts', builder: (context, state) => PostScreen()),
      GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
      GoRoute(path: '/messages', builder: (context, state) => MessageScreen()),
      GoRoute(path: '/settings', builder: (context, state) => SettingScreen()),
    ],
  );
});
