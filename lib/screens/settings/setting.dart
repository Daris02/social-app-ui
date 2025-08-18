import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:social_app/constant/helpers.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/screens/settings/components/setting_switch.dart';
import 'package:social_app/screens/settings/edit_account.dart';
import 'package:social_app/theme/dark_mode.dart';
import 'package:social_app/theme/theme_provider.dart';
import 'package:social_app/utils/main_drawer.dart';
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
    final theme = ref.watch(themeProvider);
    if (user == null) {
      return CircularProgressIndicator();
    }
    if (theme == darkMode) {
      isDarkMode = true;
    } else {
      isDarkMode = false;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres'),
      ),
      drawer: isDesktop(context)
          ? null
          : MainDrawer(),
      body: Container(
        constraints: BoxConstraints(maxWidth: 700),
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Compte',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
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
                  icon: isDarkMode
                      ? HugeIcons.strokeRoundedMoonEclipse
                      : HugeIcons.strokeRoundedMoon,
                  onTap: (value) {
                    setState(() {
                      ref.read(themeProvider.notifier).toggleTheme();
                      isDarkMode = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                SettingItem(
                  colorSchema: colorSchema,
                  title: 'Se déconnecter',
                  bgColor: Colors.red.shade100,
                  iconColor: Colors.red,
                  icon: HugeIcons.strokeRoundedLogout01,
                  onTap: () async {
                    final success = await ref
                        .read(userProvider.notifier)
                        .logout();
                    if (success) router.go('/login');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
