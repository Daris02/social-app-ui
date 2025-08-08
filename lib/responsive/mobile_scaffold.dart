import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MobileScaffold extends ConsumerWidget {
  final Widget child;
  const MobileScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // appBar: myAppBar(context),
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: child,
    );
  }
}
