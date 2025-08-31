import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:social_app/constant/helpers.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/screens/settings/edit_account.dart';
import 'package:social_app/theme/dark_mode.dart';
import 'package:social_app/theme/theme_provider.dart';
import 'package:social_app/utils/main_drawer.dart';
import 'package:url_launcher/url_launcher.dart';
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
  String _getThemeLabel(WidgetRef ref) {
    final notifier = ref.read(themeProvider.notifier);
    switch (notifier.currentMode) {
      case AppThemeMode.claire:
        return "Clair";
      case AppThemeMode.sombre:
        return "Sombre";
      case AppThemeMode.system:
        return "Système";
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(themeProvider.notifier);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Choisir un thème"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
            return RadioListTile<AppThemeMode>(
              title: Text(mode.name),
              value: mode,
              groupValue: notifier.currentMode,
              onChanged: (val) {
                if (val != null) {
                  notifier.setThemeMode(val);
                  Navigator.pop(ctx);
                  setState(() {});
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

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
      appBar: AppBar(title: Text('Paramètres')),
      drawer: isDesktop(context) ? null : MainDrawer(),
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
                        icon: HugeIcons.strokeRoundedUserCircle,
                        color: const Color.fromARGB(255, 145, 145, 145),
                        size: 50,
                      ),
                      const SizedBox(width: 10),
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
                  title: 'Thème',
                  value: _getThemeLabel(ref),
                  bgColor: Colors.purple.shade100,
                  iconColor: Colors.purple,
                  icon: Icons.color_lens,
                  onTap: () => _showThemeDialog(context, ref),
                ),
                const SizedBox(height: 20),
                SettingItem(
                  colorSchema: colorSchema,
                  title: 'À propos du sénat',
                  bgColor: Colors.blue.shade100,
                  iconColor: Colors.blue,
                  icon: HugeIcons.strokeRoundedInformationCircle,
                  onTap: () async {
                    final Uri url = Uri.parse('https://senat.mg');
                    if (!await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    )) {
                      throw Exception('Could not launch $url');
                    }
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
