import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/utils/main_drawer.dart';

class DesktopScaffold extends ConsumerWidget {
  final Widget child;
  const DesktopScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Row(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: MainDrawer(),
          ),

          Expanded(
            flex: 2,
            child: child,
          ),

          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
              ),
              // child: (child.==(MessageScreen)) ? Center(child: Text('message'),): null,
            ),
          ),
        ],
      ),
    );
  }
}
