import 'package:flutter/material.dart';
import 'package:social_app/responsive/desktop_scaffold.dart';
import 'package:social_app/responsive/mobile_scaffold.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    return isDesktop ? const DesktopScaffold() : const MobileScaffold();
  }
}
