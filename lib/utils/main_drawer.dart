import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/src/router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:social_app/constant/helpers.dart';
import 'package:social_app/routes/app_router.dart';

class MainDrawer extends ConsumerStatefulWidget {
  const MainDrawer({super.key});

  @override
  ConsumerState<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends ConsumerState<MainDrawer> {
  final _searchController = TextEditingController();
  final FocusNode _keyboardFocus = FocusNode();
  final padding = EdgeInsets.symmetric(horizontal: 5);

  @override
  void dispose() {
    _keyboardFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    border: BoxBorder.all(color: Colors.transparent),
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
                  KeyboardListener(
                    focusNode: _keyboardFocus..requestFocus(),
                    onKeyEvent: (KeyEvent event) {
                      if (event is KeyDownEvent) {
                        if (event.logicalKey == LogicalKeyboardKey.enter) {
                          if (!isDesktop(context)) Navigator.pop(context);
                          router.replace(
                            '/search',
                            extra: _searchController.text,
                          );
                        }
                      }
                    },
                    child: Row(
                      children: [
                        Expanded(child: buildSearchField(colorScheme)),
                        IconButton(
                          icon: Icon(
                            Icons.search,
                            color: colorScheme.inversePrimary,
                          ),
                          onPressed: () {
                            if (!isDesktop(context)) Navigator.pop(context);
                            router.replace(
                              '/search',
                              extra: _searchController.text,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
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
      controller: _searchController,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        hintText: 'Rechercher ...',
        hintStyle: TextStyle(color: color.withAlpha(150)),
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
