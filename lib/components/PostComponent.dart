import 'package:flutter/material.dart';

import '../models/user.dart';

class PostComponent extends StatelessWidget {
  final title;
  final content;
  final User author;

  const PostComponent({
    Key? key,
    required this.title,
    required this.content,
    required this.author,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: $title'),
            Text('Content: $content'),
            Text('Author: ${author.lastName}'),
          ],
        ),
      ),
    );
  }
}
