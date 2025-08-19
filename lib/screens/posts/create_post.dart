import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:social_app/services/post_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  List<PlatformFile>? mediaFiles;
  List<PlatformFile>? pickedFiles;
  bool isLoading = false;
  String? statusMessage;
  bool isSuccess = false;

  Future<void> pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        mediaFiles = result.files;
      });
    }
  }

  Future<void> publishPost() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    debugPrint('Publishing post ...');

    if (title.isEmpty) return;

    setState(() {
      isLoading = true;
      statusMessage = null;
      isSuccess = false;
    });

    try {
      await PostService.createPost(title, content, files: mediaFiles);

      setState(() {
        isLoading = false;
        isSuccess = true;
        statusMessage = "Publication envoyée avec succès ✅";
      });

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        isLoading = false;
        isSuccess = false;
        statusMessage = "Erreur lors de l’envoi ❌ : $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color colorTheme = Theme.of(context).colorScheme.inversePrimary;
    return Scaffold(
      appBar: AppBar(title: const Text("Nouvelle publication")),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Titre'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'Contenu'),
                ),
                const SizedBox(height: 12),
                if (mediaFiles != null)
                  Container(
                    height: 150,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(border: Border.all()),
                    child: ListView.builder(
                      itemCount: mediaFiles?.length,
                      itemBuilder: (context, index) {
                        if (mediaFiles!.isEmpty) return null;
                        final mediaFile = mediaFiles?[index];
                        return _buildFilePreview(mediaFile!);
                      },
                    ),
                  ),

                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: Icon(Icons.attach_file, color: colorTheme),
                  label: Text(
                    "Ajouter une image ou vidéo",
                    style: TextStyle(color: colorTheme),
                  ),
                  onPressed: pickMedia,
                ),
                const SizedBox(height: 24),
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    ),
                  ),

                if (statusMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      statusMessage!,
                      style: TextStyle(
                        color: isSuccess ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ElevatedButton(
                  onPressed: publishPost,
                  child: Text("Publier", style: TextStyle(color: colorTheme)),)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilePreview(PlatformFile file) {
    final ext = file.extension?.toLowerCase() ?? '';
    final path = file.path ?? '';

    if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) {
      debugPrint('Image: $ext');
      return Image.file(File(path), fit: BoxFit.cover);
    } else if (['mp4', 'mov', 'mkv', 'webm'].contains(ext)) {
      return const Center(
        child: Icon(Icons.videocam, size: 48, color: Colors.grey),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.insert_drive_file, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              ext.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
  }
}
