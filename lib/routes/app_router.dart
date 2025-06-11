import 'package:go_router/go_router.dart';
import 'package:social_app/screens/call.dart';
import 'package:social_app/screens/chat.dart';
import 'package:social_app/screens/login.dart';
import 'package:social_app/screens/register.dart';
import 'package:social_app/screens/post.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => RegisterScreen()),
    GoRoute(path: '/annonces', builder: (_, __) => AnnoncesScreen()),
    GoRoute(path: '/chat', builder: (_, __) => ChatScreen()),
    GoRoute(path: '/call', builder: (_, __) => CallScreen()),
  ],
);
