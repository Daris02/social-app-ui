import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/responsive/desktop_scaffold.dart';
import 'package:social_app/responsive/mobile_scaffold.dart';
import 'package:social_app/responsive/responsive_layout.dart';
import 'package:social_app/screens/setting.dart';
import 'package:social_app/screens/posts/post.dart';
import 'package:social_app/screens/notification.dart';
import 'package:social_app/screens/messages/message.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState createState() => _HomeState();
}

class _HomeState extends ConsumerState<HomeScreen> {
  int pageIndex = 0;
  final pages = [PostScreen(), MessageScreen(), NotificationScreen(), SettingScreen()];

  @override
  Widget build(BuildContext context) {
    return 
    ResponsiveLayout(mobileScaffold: MobileScaffold(), desktopScaffold: DesktopScaffold());
    // Scaffold(
    //   body: pages[pageIndex],
    //   bottomNavigationBar: NavigationBar(
    //     backgroundColor: Theme.of(context).colorScheme.surface,
    //     height: 55,
    //     selectedIndex: pageIndex,
    //     onDestinationSelected: (index) => {
    //       setState(() {
    //         pageIndex = index;
    //       }),
    //     },
    //     destinations: [
    //       NavigationDestination(
    //         icon: Icon(Icons.blur_circular_outlined),
    //         label: '',
    //       ),
    //       NavigationDestination(icon: Icon(Icons.message), label: ''),
    //       NavigationDestination(icon: Icon(Icons.notifications), label: '',),
    //       NavigationDestination(
    //         icon: Icon(Icons.view_list_rounded),
    //         label: '',
    //       ),
    //     ],
    //   ),
    // );
  }
}
