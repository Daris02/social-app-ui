import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:social_app/models/direction.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/providers/auth_provider.dart';
import 'package:social_app/theme/dark_mode.dart';
import 'package:social_app/theme/light_mode.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(DirectionAdapter());
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox<User>('userBox');
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final init = ref.watch(authInitProvider);

    return init.when(
      loading: () => MaterialApp(
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, _) => MaterialApp(
        home: const Scaffold(
          body: Center(child: Text("Erreur init")),
        ),
      ),
      data: (_) {
        final appRouter = ref.watch(appRouterProvider);
        return MaterialApp.router(
          title: 'Flutter App Auth',
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          theme: lightMode,
          darkTheme: darkMode,
        );
      },
    );
  }
}

