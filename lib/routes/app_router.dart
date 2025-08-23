import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/main.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/responsive/desktop_scaffold.dart';
import 'package:social_app/responsive/mobile_scaffold.dart';
import 'package:social_app/screens/auth/forgot_password.dart';
import 'package:social_app/screens/auth/login.dart';
import 'package:social_app/screens/auth/register.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/screens/messages/messages.dart';
import 'package:social_app/screens/posts/post.dart';
import 'package:social_app/screens/profile/profile.dart';
import 'package:social_app/screens/search/search_screen.dart';
import 'package:social_app/screens/settings/setting.dart';

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
    navigatorKey: navigatorKey,
    refreshListenable: GoRouterRefreshStream(
      ref.watch(userProvider.notifier).stream,
    ),
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
        redirect: (context, state) {
          final user = ref.read(userProvider);
          if (user != null) return '/';
          return null;
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPassword(),
      ),

      ShellRoute(
        builder: (context, state, child) {
          final isDesktop = MediaQuery.of(context).size.width >= 900;
          return isDesktop
              ? DesktopScaffold(child: child)
              : MobileScaffold(child: child);
        },
        routes: [
          GoRoute(path: '/', builder: (_, __) => const PostScreen()),
          GoRoute(path: '/messages', builder: (_, __) => const MessageScreen()),
          GoRoute(
            path: '/profile',
            builder: (context, state) {
              final user = state.extra as User;
              return ProfileScreen(user: user);
            },
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) {
              final valueSearch = state.extra as String;
              return SearchScreen(valueSearch: valueSearch);
            },
          ),
          GoRoute(path: '/settings', builder: (_, __) => const SettingScreen()),
        ],
      ),
    ],
  );
});
