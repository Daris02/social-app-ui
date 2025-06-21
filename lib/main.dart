import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/constant/api.dart';
import 'package:social_app/providers/user_provider.dart';
import 'routes/app_router.dart';
import 'package:social_app/theme/dark_mode.dart';
import 'package:social_app/theme/light_mode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  DioClient.init();
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final init = ref.watch(userInitProvider);

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

