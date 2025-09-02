import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/constant/helpers.dart';
import 'package:social_app/utils/main_drawer.dart';

class Live extends ConsumerStatefulWidget {
  const Live({ super.key });

  @override
  ConsumerState createState() => _LiveState();
}

class _LiveState extends ConsumerState<Live> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TV & Radio'),
      ),
      drawer: isDesktop(context) ? null : MainDrawer(),
      body: Center(
        child: Text('Live TV & Radio'),
      ),
    );
  }
}