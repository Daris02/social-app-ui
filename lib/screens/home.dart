import 'package:flutter/material.dart';
import 'package:social_app/screens/call.dart';
import 'package:social_app/screens/chat.dart';
import 'package:social_app/screens/post.dart';
import 'package:social_app/screens/setting.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  int pageIndex = 0;
  final pages = [PostScreen(), ChatScreen(), CallScreen(), SettingScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[pageIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: pageIndex,
        onDestinationSelected: (index) => {
          setState(() {
            pageIndex = index;
          }),
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.blur_circular_outlined),
            label: 'Posts',
          ),
          NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.phone), label: 'Call'),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Setting',
          ),
        ],
      ),
    );
  }
}
