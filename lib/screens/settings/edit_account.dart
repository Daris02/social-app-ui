import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

class EditAccountScreen extends ConsumerStatefulWidget {
  const EditAccountScreen({super.key});

  @override
  ConsumerState createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends ConsumerState<EditAccountScreen> {
  @override
  Widget build(BuildContext context) {
    final colorSchema = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () { },
            style: IconButton.styleFrom(
              backgroundColor: Colors.lightBlueAccent,
            ),
            icon: Icon(Icons.check, color: colorSchema.inversePrimary,),
          ),
        ],
        leadingWidth: 80,
      ),
      body: Center(),
    );
  }
}
