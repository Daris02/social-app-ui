import 'package:flutter/material.dart';

class ForwardButton extends StatelessWidget {
  final Function() onTap;
  const ForwardButton({
    super.key,
    required this.colorSchema,
    required this.onTap,
  });

  final ColorScheme colorSchema;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorSchema.secondary,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
