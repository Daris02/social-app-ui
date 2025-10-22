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
      child: Icon(
        Icons.chevron_right_rounded,
        color: colorSchema.inversePrimary,
        applyTextScaling: true,
        size: 40,
      ),
    );
  }
}
