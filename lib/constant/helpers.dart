import 'package:flutter/material.dart';

PreferredSizeWidget myAppBar(BuildContext context) => AppBar(
  backgroundColor: Theme.of(context).primaryColor,
  title: Text(
    'S O C I A L  A P P',
    style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
  ),
  centerTitle: true,
);

bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 900;

Drawer myDrawer(BuildContext context, dynamic router, dynamic userProvider) {
  final isMobileScreen = MediaQuery.of(context).size.width < 900;

  void closeDrawerIfNeeded() {
    if (isMobileScreen) Navigator.pop(context);
  }

  return Drawer(
    backgroundColor: Theme.of(context).colorScheme.surface,
    child: Column(
      children: [
        DrawerHeader(
          child: ListTile(
            leading: Image.asset('assets/logos/logo-senat.png'),
            title: const Text('S O C I A L  A P P'),
            onTap: () {
              closeDrawerIfNeeded();
              router.go('/');
            },
          ),
        ),

        ListTile(
          leading: const Icon(Icons.chat_rounded),
          title: const Text('M E S S A G E'),
          onTap: () {
            closeDrawerIfNeeded();
            router.go('/messages');
          },
        ),

        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('P R O F I L E'),
          onTap: () {
            closeDrawerIfNeeded();
            router.go('/profile');
          },
        ),

        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('S E T T I N G'),
          onTap: () {
            closeDrawerIfNeeded();
            router.go('/settings');
          },
        ),

        // ListTile(
        //   leading: const Icon(Icons.exit_to_app),
        //   title: const Text('D E C O N N E C T E R'),
        //   onTap: () async {
        //     final success = await userProvider.logout();
        //     if (success) router.go('/login');
        //   },
        // ),
      ],
    ),
  );
}
