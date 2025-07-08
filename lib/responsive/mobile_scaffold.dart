import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:social_app/constant/helpers.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/routes/app_router.dart';
import 'package:social_app/screens/messages/message.dart';
import 'package:social_app/screens/notification.dart';
import 'package:social_app/screens/posts/post.dart';
import 'package:social_app/screens/setting.dart';

class MobileScaffold extends ConsumerStatefulWidget {
  const MobileScaffold({super.key});

  @override
  ConsumerState createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends ConsumerState<MobileScaffold> {
  int pageIndex = 0;
  final pages = [
    PostScreen(),
    NotificationScreen(),
    MessageScreen(),
    SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = ref.read(userProvider.notifier);
    final router = ref.read(appRouterProvider);
    return
    // Scaffold(
    //   body: pages[pageIndex],
    //   bottomNavigationBar: Container(
    //     color: Theme.of(context).colorScheme.primary,
    //     child: Padding(
    //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
    //       child: GNav(
    //         backgroundColor: Theme.of(context).colorScheme.primary,
    //         color: Theme.of(context).colorScheme.inversePrimary,
    //         activeColor: Theme.of(context).colorScheme.inversePrimary,
    //         tabBackgroundColor: Theme.of(
    //           context,
    //         ).colorScheme.inversePrimary.withAlpha(800),
    //         padding: EdgeInsets.all(5),
    //         onTabChange: (index) => {
    //           setState(() {
    //             pageIndex = index;
    //           }),
    //         },
    //         selectedIndex: pageIndex,
    //         gap: 8,
    //         tabs: [
    //           GButton(icon: Icons.blur_circular_outlined, text: 'Posts'),
    //           GButton(icon: Icons.search, text: 'Search'),
    //           GButton(icon: Icons.message, text: 'Message'),
    //           GButton(icon: Icons.settings, text: 'Setting'),
    //         ],
    //       ),
    //     ),
    //   ),
    Scaffold(
      appBar: myAppBar(context),
      backgroundColor: Theme.of(context).colorScheme.primary,
      drawer: myDrawer(context, router, provider),
      body: Column(
        children: [
          Expanded(
            child: PostScreen(),
          ),
        ],
      ),
    );
  }
}
