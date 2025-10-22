import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:social_app/theme/theme_provider.dart';

import 'forward_button.dart';

class SettingItem extends StatelessWidget {
  final String title;
  final String? value;
  final Color bgColor;
  final Color iconColor;
  final IconData icon;
  final Function()? onTap;
  final ThemeNotifier? notifier;
  const SettingItem({
    super.key,
    required this.colorSchema,
    required this.title,
    this.value,
    required this.bgColor,
    required this.iconColor,
    required this.icon,
    this.onTap,
    this.notifier,
  });

  final ColorScheme colorSchema;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withAlpha(100),
              ),
              child: HugeIcon(icon: icon, color: iconColor),
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            value != null
                ? Text(
                    value!,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorSchema.secondary,
                    ),
                  )
                : const SizedBox(),
            const SizedBox(width: 10),
            if (title.contains('propos'))
              ForwardButton(colorSchema: colorSchema, onTap: onTap!),
            if (title.contains('Thème'))
              SizedBox(
                width: 100,
                child: DropdownButtonFormField<AppThemeMode>(
                  initialValue: notifier!.currentMode,
                  items: AppThemeMode.values
                      .map(
                        (themeValue) => DropdownMenuItem(
                          value: themeValue,
                          child: Text(themeValue.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => notifier?.setThemeMode(v!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
