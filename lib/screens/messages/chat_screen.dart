import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/constant/helpers.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/models/message.dart';
import 'package:social_app/providers/ws_provider.dart';
import 'package:social_app/providers/user_provider.dart';
import 'package:social_app/services/message_service.dart';
import 'package:social_app/services/call_service.dart';
import 'package:social_app/screens/messages/call_screen.dart';
import 'package:social_app/screens/messages/components/message_list.dart';
import 'package:social_app/screens/messages/components/message_input.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final User partner;

  const ChatScreen({super.key, required this.partner});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late final WebSocketService socket;
  late final User partner;
  late final String roomId;
  List<Message> messages = [];
  bool _isPreparingCall = false;
  late StreamSubscription<Message> _messageSubscription;

  @override
  void initState() {
    super.initState();
    partner = widget.partner;
    socket = ref.read(webSocketServiceProvider);

    _messageSubscription = socket.onMessage((msg) {
      final currentUserId = ref.read(userProvider)!.id;
      if (msg.from == currentUserId) return;
      if (messages.any((m) => m.id == msg.id)) return;
      setState(() => messages.add(msg));
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    });

    fetchMessages();
  }

  void fetchMessages() async {
    final fetched = await MessageService.getMessages(partner.id);
    setState(() {
      messages = List.from(fetched)
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    });
  }

  void sendMessage({
    required String? text,
    required List<PlatformFile>? files,
    String? mediaType,
  }) async {
    final user = ref.read(userProvider)!;

    try {
      List<String> uploadedUrls = [];
      if (files != null && files.isNotEmpty) {
        uploadedUrls = await MessageService.uploadFiles(
          files: files,
          onUploadProgress: (sent, total) {
            // progress UI update possible
          },
        );
      }

      final message = Message(
        content: text,
        from: user.id,
        to: partner.id,
        createdAt: DateTime.now(),
        mediaUrls: uploadedUrls.isNotEmpty ? uploadedUrls : null,
        mediaType: mediaType,
      );

      socket.sendMessage(message);

      setState(() {
        messages.removeWhere((m) => m.isLocal == true);
        messages.add(message);
        messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Échec de l’envoi: $e')));
    }
  }

  @override
  void dispose() {
    _messageSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider)!;
    return isDesktop(context)
        ? Column(
            children: [
              Expanded(
                child: MessageList(messages: messages, currentUserId: user.id),
              ),
              MessageInput(onSend: sendMessage),
            ],
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(partner.lastName),
              actions: [
                IconButton(
                  onPressed: _isPreparingCall
                      ? null
                      : () async {
                          setState(() => _isPreparingCall = true);
                          final params = VideoCallParams(
                            user.id.toString(),
                            partner.id.toString(),
                          );
                          ref.invalidate(videoCallServiceProvider(params));
                          final callService = ref.read(
                            videoCallServiceProvider(params),
                          );

                          callService.onCallAccepted = () async {
                            if (!mounted) return;
                            setState(() => _isPreparingCall = false);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VideoCallScreen(
                                  callService: callService,
                                  isCaller: true,
                                ),
                              ),
                            );
                          };

                          callService.onCallRefused = () {
                            setState(() => _isPreparingCall = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('L’appel a été refusé'),
                              ),
                            );
                          };

                          await callService.connect(true);
                          await callService.startCall();
                        },

                  icon: Icon(Icons.video_call),
                ),
              ],
            ),
            body: _isPreparingCall
                ? LinearProgressIndicator()
                : Column(
                    children: [
                      Expanded(
                        child: MessageList(
                          messages: messages,
                          currentUserId: user.id,
                        ),
                      ),
                      MessageInput(onSend: sendMessage),
                    ],
                  ),
          );
  }
}
