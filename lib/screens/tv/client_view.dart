import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/services/live_service.dart';

class ClientView extends ConsumerStatefulWidget {
  const ClientView({super.key});

  @override
  ConsumerState createState() => _ClientViewState();
}

class _ClientViewState extends ConsumerState<ClientView> {
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  LiveStreamService? _service;

  @override
  void initState() {
    super.initState();
    _remoteRenderer.initialize();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _service = ref.read(liveStreamServiceProvider(false));
      await _service!.join();

      _service!.remoteStream.addListener(() {
        final stream = _service!.remoteStream.value;
        if (stream != null) {
          setState(() {
            _remoteRenderer.srcObject = stream;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: RTCVideoView(_remoteRenderer),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black26)],
          ),
          child: const Center(
            child: Text(
              "Vous regardez le flux en direct",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _remoteRenderer.dispose();
    _service?.leave();
    super.dispose();
  }
}
