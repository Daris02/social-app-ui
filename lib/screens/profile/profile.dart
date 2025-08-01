import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/screens/messages/chat_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late User user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    final colorSchema = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text('${user.firstName} ${user.lastName}'),
        centerTitle: true,
        actions: [],
      ),
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
                        image: NetworkImage(user.photo!),
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
                  // Text(
                  //   '${user.firstName} ${user.lastName}',
                  //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  // ),
                  Text('Direction: ${user.direction?.name}'),
                  Text('Attribution: ${user.attribution}'),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MessageView(partner: user),
                              ),
                            );
                          },
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
