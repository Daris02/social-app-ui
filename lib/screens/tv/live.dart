import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:social_app/constant/helpers.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/screens/tv/client_view.dart';
import 'package:social_app/screens/tv/liver_view.dart';
import 'package:social_app/utils/main_drawer.dart';

class Live extends ConsumerStatefulWidget {
  const Live({super.key});

  @override
  ConsumerState createState() => _LiveState();
}

class _LiveState extends ConsumerState<Live> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.read(userProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Streaming TV & Radio"),
      ),
      drawer: isDesktop(context) ? null : const MainDrawer(),
      body: currentUser?.IM == '000001'
    ? const LiverView()
    : const ClientView(),
    );
  }
}
