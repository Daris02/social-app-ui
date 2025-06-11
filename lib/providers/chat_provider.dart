import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:social_app/constant/api.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/message.dart';

final chatProvider = StateNotifierProvider<ChatController, List<Message>>((
  ref,
) {
  return ChatController();
});

class ChatController extends StateNotifier<List<Message>> {
  late final WebSocketChannel _channel;

  ChatController() : super([]) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    _channel = WebSocketChannel.connect(
      Uri.parse('$baseWSUrl?token=$token'),
    );

    _channel.stream.listen(
      (data) {
        debugPrint("[WS] Message reçu: $data");
        final json = jsonDecode(data);
        state = [...state, Message.fromJson(json)];
      },
      onError: (err) {
        print("[WS] Erreur WebSocket: $err");
      },
      onDone: () {
        print("[WS] Connexion fermée");
      },
    );
  }

  void sendMessage(Message msg) {
    final json = jsonEncode(msg.toJson());
    _channel.sink.add(json);
    state = [...state, msg];
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}
