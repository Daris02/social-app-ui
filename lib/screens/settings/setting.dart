import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:social_app/constant/helpers.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/screens/settings/edit_account.dart';
import 'package:social_app/screens/settings/update_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider);
    final router = ref.read(appRouterProvider);
    final notifier = ref.read(themeProvider.notifier);
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
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600),
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
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: colorSchema.inversePrimary
                              .withOpacity(0.3),
                          backgroundImage: user.photo != null
                              ? NetworkImage(user.photo!)
                              : null,
                          onBackgroundImageError: (error, stackTrace) {
                            if (kDebugMode) {
                              debugPrint('Error loading user photo: $error');
                            }
                          },
                          child: user.photo == null
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: colorSchema.onPrimaryContainer,
                                )
                              : null,
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
                                builder: (context) =>
                                    EditAccountScreen(user: user),
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
                    title: 'Mise à jours',
                    value: 'v1.0.111',
                    bgColor: Colors.orange.shade100,
                    iconColor: Colors.orange,
                    icon: HugeIcons.strokeRoundedInboxDownload,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UpdateScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  SettingItem(
                    colorSchema: colorSchema,
                    title: 'Thème',
                    bgColor: Colors.purple.shade100,
                    iconColor: Colors.purple,
                    icon: Icons.color_lens,
                    notifier: notifier,
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
      ),
    );
  }
}
