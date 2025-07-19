import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/constant/helpers.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/routes/app_router.dart';

class MobileScaffold extends ConsumerWidget {
  final Widget child;
  const MobileScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.read(userProvider.notifier);
    final router = ref.read(appRouterProvider);

    return Scaffold(
      // appBar: myAppBar(context),
      backgroundColor: Theme.of(context).colorScheme.primary,
      drawer: myDrawer(context, router, provider),
      body: child,
    );
  }
}
