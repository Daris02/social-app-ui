import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateScreen extends ConsumerStatefulWidget {
  const UpdateScreen({ super.key });

  @override
  ConsumerState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends ConsumerState<UpdateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mise à jours'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 15,),
            Text('Version actuelle: '),
            const SizedBox(height: 15,),
            Text('Dernier version: '),
          ],
        ),
      ),
    );
  }
}