import 'package:flutter/material.dart';

PreferredSizeWidget myAppBar(BuildContext context) => AppBar(
  backgroundColor: Theme.of(context).primaryColor,
  title: Text('S O C I A L  A P P', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
  centerTitle: true,
);

Drawer myDrawer(BuildContext context, dynamic router, dynamic userProvider) {
  return Drawer(
    backgroundColor: Theme.of(context).colorScheme.surface,
    child: Column(
      children: [
        DrawerHeader(child: Text('S O C I A L  A P P')),
        ListTile(leading: Icon(Icons.chat_rounded), title: Text('M E S S A G E'), onTap: () {
          Navigator.pop(context);
          router.push('/messages');
        },),
        ListTile(leading: Icon(Icons.person), title: Text('P R O F I L E'), onTap: () {
          Navigator.pop(context);
          router.push('/profile');
        },),
        // ListTile(leading: Icon(Icons.settings), title: Text('S E T T I N G S'), onTap: () {
        //   router.push('/settings');
        // },),
        // ListTile(
        //   leading: Icon(Icons.exit_to_app),
        //   title: Text('L O G O U T'),
        //   onTap: () async {
        //     final success = await userProvider.logout();
        //     if (success) router.go('/login');
        //   },
        // ),
      ],
    ),
  );
}
