import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final bool loading;
  final Color? color;
  final Color? textColor;

  const MyButton({
    super.key,
    required this.text,
    this.onTap,
    this.loading = false,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: loading ? null : onTap,
        child: Container(
          decoration: BoxDecoration(
            color: color ?? Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(20),
          child: Center(
            child: loading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor ?? Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
