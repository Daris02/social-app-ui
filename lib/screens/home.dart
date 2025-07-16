import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/screens/setting.dart';
import 'package:social_app/screens/posts/post.dart';
import 'package:social_app/screens/messages/message.dart';
import 'package:social_app/responsive/responsive_layout.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState createState() => _HomeState();
}

class _HomeState extends ConsumerState<HomeScreen> {
  int pageIndex = 0;
  final pages = [PostScreen(), MessageScreen(), SettingScreen()];

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout();
  }
}
