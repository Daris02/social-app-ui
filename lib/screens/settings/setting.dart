import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:social_app/constant/helpers.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/screens/settings/components/setting_switch.dart';
import 'package:social_app/screens/settings/edit_account.dart';
import '../../routes/app_router.dart';
import 'components/forward_button.dart';
import 'components/setting_item.dart';

class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState createState() => _SettingState();
}

class _SettingState extends ConsumerState<SettingScreen> {
  bool isDarkMode = false;
  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider);
    final router = ref.read(appRouterProvider);
    final colorSchema = Theme.of(context).colorScheme;
    if (user == null) {
      return CircularProgressIndicator();
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: () async {
              final success = await ref.read(userProvider.notifier).logout();
              if (success) router.go('/login');
            },
          ),
        ],
        leadingWidth: 80,
      ),
      drawer: isDesktop(context)
          ? null
          : myDrawer(context, router, userProvider),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Parametres",
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              Text(
                'Compte',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedUser,
                      color: const Color.fromARGB(255, 145, 145, 145),
                      size: 70,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.firstName} ${user.lastName}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${user.direction?.name} - ${user.attribution}',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorSchema.secondary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ForwardButton(
                      colorSchema: colorSchema,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditAccountScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Parametres',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SettingItem(
                colorSchema: colorSchema,
                title: 'Language',
                value: 'Francais',
                bgColor: Colors.orange.shade100,
                iconColor: Colors.orange,
                icon: HugeIcons.strokeRoundedEarth,
                onTap: () {},
              ),
              const SizedBox(height: 20),
              SettingItem(
                colorSchema: colorSchema,
                title: 'Notifications',
                bgColor: Colors.blue.shade100,
                iconColor: Colors.blue,
                icon: HugeIcons.strokeRoundedNotification01,
                onTap: () {},
              ),
              const SizedBox(height: 20),
              SettingSwitch(
                colorSchema: colorSchema,
                title: 'Dark Mode',
                value: isDarkMode,
                bgColor: Colors.purple.shade100,
                iconColor: Colors.purple,
                icon: HugeIcons.strokeRoundedEarth,
                onTap: (value) {
                  setState(() {
                    isDarkMode = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              SettingItem(
                colorSchema: colorSchema,
                title: 'Aide',
                bgColor: Colors.red.shade100,
                iconColor: Colors.red,
                icon: HugeIcons.strokeRoundedEarth,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
      //   Padding(
      //     padding: EdgeInsetsGeometry.all(20),
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.start,
      //       spacing: 20,
      //       children: [
      //         Row(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           spacing: 10,
      //           children: [
      //             Icon(Icons.person),
      //             Text('${user?.firstName} ${user?.lastName}'),
      //           ],
      //         ),
      //         Row(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           spacing: 10,
      //           children: [Icon(Icons.email), Text('${user?.email}')],
      //         ),
      //         Row(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           spacing: 10,
      //           children: [Icon(Icons.phone), Text('${user?.phone}')],
      //         ),
      //         Row(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           spacing: 10,
      //           children: [Icon(Icons.info), Text('Info plus ...')],
      //         ),

      //         GestureDetector(
      //           onTap: () async {
      //             final success = await ref.read(userProvider.notifier).logout();
      //             if (success) router.go('/login');
      //           },
      //           child: Row(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             spacing: 10,
      //             children: [Icon(Icons.exit_to_app), Text('Se déconnecter')],
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
    );
  }
}
