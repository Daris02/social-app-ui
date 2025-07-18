import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/constant/helpers.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/routes/app_router.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final colorSchema = Theme.of(context).colorScheme;
    final router = ref.read(appRouterProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Profile'), centerTitle: true, actions: [
        ],
      ),
      drawer: isDesktop(context)
          ? null
          : myDrawer(context, router, userProvider),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          child: ListView(
            children: [
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorSchema.inversePrimary,
                      image: DecorationImage(
                        image: NetworkImage(user!.photo!),
                        fit: BoxFit.cover,
                        onError: (error, stackTrace) {
                          if (kDebugMode) {
                            debugPrint('Error loading user photo: $error');
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text('Direction: ${user.direction?.name}'),
                  Text('Attribution: ${user.attribution}'),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {},
                          label: Text(
                            'Message',
                            style: TextStyle(color: colorSchema.inversePrimary),
                          ),
                          icon: Icon(
                            Icons.message_rounded,
                            color: colorSchema.inversePrimary,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          label: Text(
                            'Call',
                            style: TextStyle(color: colorSchema.inversePrimary),
                          ),
                          icon: Icon(
                            Icons.call,
                            color: colorSchema.inversePrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
