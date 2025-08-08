import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/src/router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:social_app/constant/helpers.dart';
import 'package:social_app/routes/app_router.dart';

class MainDrawer extends ConsumerWidget {
  MainDrawer({super.key});
  final padding = EdgeInsets.symmetric(horizontal: 5);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final router = ref.read(appRouterProvider);
    final urlImage = 'assets/logos/logo-senat.png';

    void closeDrawerIfNeeded() {
      if (!isDesktop(context)) Navigator.pop(context);
    }

    return Drawer(
      child: Material(
        color: colorScheme.surface,
        child: ListView(
          padding: padding,
          children: [
            GestureDetector(
              onTap: () {
                closeDrawerIfNeeded();
                router.go('/');
              },
              child: SizedBox(
                child: Container(
                  decoration: BoxDecoration(
                    border: BoxBorder.all(
                      color: Colors.transparent,
                    )
                  ),
                  child: buildHeader(
                    urlImage: urlImage,
                    text: 'Social App',
                    colorScheme: colorScheme,
                    router: router,
                  ),
                ),
              ),
            ),
            Container(
              padding: padding,
              child: Column(
                children: [
                  buildSearchField(colorScheme),
                  const SizedBox(height: 20),
                  buildMenuItem(
                    text: 'Message',
                    icon: HugeIcons.strokeRoundedMessage02,
                    colorScheme: colorScheme,
                    router: router,
                    onTap: () {
                      closeDrawerIfNeeded();
                      router.go('/messages');
                    },
                  ),
                  const SizedBox(height: 5),
                  buildMenuItem(
                    text: 'Parametres',
                    icon: HugeIcons.strokeRoundedSetting06,
                    colorScheme: colorScheme,
                    router: router,
                    onTap: () {
                      closeDrawerIfNeeded();
                      router.go('/settings');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader({
    required String urlImage,
    required String text,
    required ColorScheme colorScheme,
    required GoRouter router,
  }) {
    return Container(
      padding: padding.add(EdgeInsets.symmetric(vertical: 40)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: Image.asset(urlImage).image,
          ),
          SizedBox(width: 20),
          Text(
            text,
            style: TextStyle(fontSize: 20, color: colorScheme.inversePrimary),
          ),
        ],
      ),
    );
  }

  buildSearchField(ColorScheme colorScheme) {
    final color = colorScheme.inversePrimary;
    return TextField(
      style: TextStyle(color: color),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        hintText: 'Search',
        hintStyle: TextStyle(color: color),
        prefixIcon: Icon(Icons.search, color: color),
        filled: true,
        fillColor: color.withAlpha(12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: color.withAlpha(70)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: color.withAlpha(70)),
        ),
      ),
    );
  }

  Widget buildMenuItem({
    required String text,
    required IconData icon,
    required ColorScheme colorScheme,
    required GoRouter router,
    required Function() onTap,
  }) {
    final color = colorScheme.inversePrimary;
    final hoverColor = colorScheme.inversePrimary.withAlpha(25);

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text, style: TextStyle(color: color)),
      hoverColor: hoverColor,
      onTap: onTap,
    );
  }
}
