import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
class MessageInput extends StatefulWidget {
  final Function({
    required String? text,
    required List<PlatformFile>? files,
    String? mediaType,
  }) onSend;

  const MessageInput({super.key, required this.onSend});

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final controller = TextEditingController();
  List<PlatformFile>? _selectedFiles;
  String? _mediaType;

  void handleSend() {
    if ((_selectedFiles != null && _selectedFiles!.isNotEmpty) ||
        controller.text.trim().isNotEmpty) {
      widget.onSend(
        text: _selectedFiles == null ? controller.text.trim() : null,
        files: _selectedFiles,
        mediaType: _mediaType,
      );
      controller.clear();
      setState(() {
        _selectedFiles = null;
        _mediaType = null;
      });
    }
  }

  Future<void> pickFiles(String mediaType) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: mediaType == 'image'
          ? FileType.image
          : mediaType == 'video'
              ? FileType.video
              : FileType.custom,
      allowedExtensions:
          mediaType == 'document' ? ['pdf', 'doc', 'docx', 'txt'] : null,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFiles = result.files;
        _mediaType = mediaType;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.image),
            onPressed: () => pickFiles('image'),
          ),
          IconButton(
            icon: Icon(Icons.videocam),
            onPressed: () => pickFiles('video'),
          ),
          IconButton(
            icon: Icon(Icons.attach_file),
            onPressed: () => pickFiles('document'),
          ),
          Expanded(
            child: _selectedFiles == null
                ? TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onSubmitted: (_) => handleSend(),
                    textInputAction: TextInputAction.send,
                  )
                : SizedBox(
                    height: 60,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _selectedFiles!.map((file) {
                        if (_mediaType == 'image') {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Image.file(
                              File(file.path!),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          );
                        } else {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.insert_drive_file, size: 30),
                                Text(
                                  file.name,
                                  style: TextStyle(fontSize: 10),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        }
                      }).toList(),
                    ),
                  ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: handleSend,
          ),
        ],
      ),
    );
  }
}
