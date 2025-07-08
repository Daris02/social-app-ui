import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/constant/helpers.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/routes/app_router.dart';
import 'package:social_app/screens/posts/post.dart';

class DesktopScaffold extends ConsumerStatefulWidget {
  const DesktopScaffold({super.key});

  @override
  ConsumerState createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends ConsumerState<DesktopScaffold> {
  @override
  Widget build(BuildContext context) {
    final provider = ref.read(userProvider.notifier);
    final router = ref.read(appRouterProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Row(
        children: [
          // open drawer
          Container(child: myDrawer(context, router, provider)),

          // rest of body
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  child: PostScreen(),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [Expanded(child: Container(color: Colors.amberAccent))],
            ),
          ),
        ],
      ),
    );
  }
}
