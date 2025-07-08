import 'package:flutter/material.dart';

PreferredSizeWidget myAppBar(BuildContext context) => AppBar(
  backgroundColor: Theme.of(context).primaryColor,
  title: Text('S O C I A L  A P P', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
  centerTitle: true,
  actions: [
    // IconButton(
    //   icon: Icon(Icons.notifications, color: Colors.white),
    //   onPressed: () {
    //     // Handle notifications
    //   },
    // ),
    // IconButton(
    //   icon: Icon(Icons.account_circle, color: Colors.white),
    //   onPressed: () {
    //     // Handle user profile
    //   },
    // ),
  ],
);

Drawer myDrawer(BuildContext context, dynamic router, dynamic userProvider) {
  return Drawer(
    backgroundColor: Theme.of(context).colorScheme.primary,
    
    child: Column(
      children: [
        DrawerHeader(child: Text('S O C I A L  A P P')),
        ListTile(leading: Icon(Icons.home), title: Text('D A S H B O A R D'), onTap: () {
          router.push('/posts');
        },),
        ListTile(leading: Icon(Icons.chat), title: Text('M E S S A G E'), onTap: () {
          router.push('/messages');
        },),
        ListTile(leading: Icon(Icons.settings), title: Text('S E T T I N G S'), onTap: () {
          router.push('/settings');
        },),
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
