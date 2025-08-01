import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class SettingSwitch extends StatelessWidget {
  final String title;
  final bool value;
  final Color bgColor;
  final Color iconColor;
  final IconData icon;
  final Function(bool value) onTap;
  const SettingSwitch({
    super.key,
    required this.colorSchema,
    required this.title,
    required this.value,
    required this.bgColor,
    required this.iconColor,
    required this.icon,
    required this.onTap,
  });

  final ColorScheme colorSchema;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.shade100,
            ),
            child: HugeIcon(icon: icon, color: iconColor),
          ),
          const SizedBox(width: 40),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            value ? "On" : "Off",
            style: TextStyle(fontSize: 14, color: colorSchema.secondary),
          ),
          const SizedBox(width: 10),
          CupertinoSwitch(value: value, onChanged: onTap)
        ],
      ),
    );
  }
}
