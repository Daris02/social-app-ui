import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_app/services/post_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  XFile? mediaFile;

  Future<void> pickMedia() async {
    final ImagePicker picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery); // ou pickVideo
    if (picked != null) {
      setState(() => mediaFile = picked);
    }
  }

  Future<void> publishPost() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty || content.isEmpty) return;

    await PostService.createPost(
      title,
      content,
      file: mediaFile,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nouvelle publication")),
      body: Padding(
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
            if (mediaFile != null)
              Container(
                height: 150,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: Image.file(File(mediaFile!.path), fit: BoxFit.cover),
              ),
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: const Text("Ajouter une image ou vidéo"),
              onPressed: pickMedia,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: publishPost,
              child: const Text("Publier"),
            ),
          ],
        ),
      ),
    );
  }
}
