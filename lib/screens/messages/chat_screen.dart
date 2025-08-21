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
  late User partner;
  late final String roomId;
  List<Message> messages = [];
  bool _isPreparingCall = false;
  StreamSubscription<Message>? _messageSub;

  @override
  void initState() {
    super.initState();
    partner = widget.partner;
    socket = ref.read(webSocketServiceProvider);

    _messageSub = socket.messages.listen((msg) {
      if (!mounted) return;
      setState(() {
        final idx = messages.indexWhere(
          (m) =>
              (m.tempId != null && m.tempId == msg.tempId) ||
              (m.id != null && m.id == msg.id),
        );

        if (idx != -1) {
          messages[idx] = msg.copyWith(status: MessageStatus.sent);
        } else {
          messages.add(msg.copyWith(status: MessageStatus.sent));
        }

        messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      });
    });

    fetchMessages();
  }

  Future<void> fetchMessages() async {
    final fetched = await MessageService.getMessages(widget.partner.id);
    setState(() {
      messages = fetched..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    });
  }

  void sendMessage({
    required String? text,
    required List<PlatformFile>? files,
    String? mediaType,
  }) async {
    final user = ref.read(userProvider)!;
    final tempId = DateTime.now().millisecondsSinceEpoch;

    var tempMessage = Message(
      id: null,
      tempId: tempId,
      from: user.id,
      to: widget.partner.id,
      content: text,
      createdAt: DateTime.now(),
      mediaType: mediaType,
      status: MessageStatus.sending,
    );

    setState(() {
      messages.add(tempMessage);
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    });

    try {
      List<String> uploadedUrls = [];
      if (files != null && files.isNotEmpty) {
        uploadedUrls = await MessageService.uploadFiles(files: files);
      }

      final finalMsg = tempMessage.copyWith(mediaUrls: uploadedUrls);
      socket.sendMessage(finalMsg);
    } catch (e) {
      setState(() {
        final idx = messages.indexWhere((m) => m.tempId == tempId);
        if (idx != -1) {
          messages[idx] = tempMessage.copyWith(status: MessageStatus.failed);
        }
      });
    }
  }

  deleteMessage(int id) {
    MessageService.removeMessage(id);
    setState(() {
      messages.removeWhere((m) => m.id == id);
    });
  }

  updateMessage(msg) {
    // final updatedMsg = await MessageService.updateMessage(msg);
    setState(() {
      final idx = messages.indexWhere((m) => m.id == msg.id);
      // if (idx != -1) messages[idx] = updatedMsg;
    });
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(userProvider)!;
    final params = VideoCallParams(user.id.toString(), partner.id.toString());
    ref.invalidate(videoCallServiceProvider(params));
    final callService = ref.read(videoCallServiceProvider(params));
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
                ?_isPreparingCall
                    ? null
                    : IconButton(
                        onPressed: () async {
                          setState(() => _isPreparingCall = true);

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
                ? Column(
                    children: [
                      LinearProgressIndicator(),
                      SizedBox(height: 300),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Appel ${partner.firstName} ${partner.lastName} ...',
                            ),
                            const SizedBox(height: 12),
                            IconButton(
                              icon: Icon(Icons.call_end, color: Colors.red),
                              iconSize: 75,
                              onPressed: () async {
                                callService.hangUp(ref);
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(
                        child: MessageList(
                          messages: messages,
                          currentUserId: user.id,
                          onDelete: (msg) => deleteMessage(msg.id!),
                          onUpdate: (msg) => updateMessage(msg),
                        ),
                      ),
                      MessageInput(onSend: sendMessage),
                    ],
                  ),
          );
  }
}
