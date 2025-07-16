import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/providers/user_provider.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.settings))],
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          child: ListView(
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user!.photo!),
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
                          icon: Icon(Icons.message_rounded, color: colorSchema.inversePrimary,),
                          
                        ),
                        ElevatedButton.icon(
                          onPressed: () {},
                          label: Text(
                            'Call',
                            style: TextStyle(color: colorSchema.inversePrimary),
                          ),
                          icon: Icon(Icons.call, color: colorSchema.inversePrimary,),
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
