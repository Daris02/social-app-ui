import 'package:go_router/go_router.dart';
import 'package:social_app/screens/call.dart';
import 'package:social_app/screens/chat.dart';
import 'package:social_app/screens/home.dart';
import 'package:social_app/screens/login.dart';
import 'package:social_app/screens/register.dart';
import 'package:social_app/screens/post.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => HomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => RegisterScreen()),
  ],
);
