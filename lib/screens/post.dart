import 'package:flutter/material.dart';
import 'package:social_app/providers/post_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

class PostScreen extends ConsumerWidget {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  PostScreen({super.key});

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Nouvelle Publications"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Titre"),
            ),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: "Contenue"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await ApiService.createPost(
                _titleController.text,
                _contentController.text,
              );
              _titleController.clear();
              _contentController.clear();
              // ignore: unused_result
              ref.refresh(postProvider);
              Navigator.pop(context);
            },
            child: Text("Publier"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Publications"),
        actions: [
          IconButton(
            icon: Icon(Icons.add_box_outlined),
            onPressed: () => _showCreateDialog(context, ref),
            tooltip: 'Create Post',
          ),
        ],
      ),
      body: posts.when(
        data: (data) => data.isEmpty ? Text('No post') : ListView.builder(
          itemCount: data.length,
          itemBuilder: (_, i) {
            final a = data[i];
            return ListTile(
              title: Text(a.title),
              subtitle: Text("${a.content}\nAuteur: ${a.author.lastName}"),
              isThreeLine: true,
            );
          },
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) {
          print("Erreur lors du chargement des publications: $e");
          return Center(child: Text("Erreur de chargement"));
        },
      ),
    );
  }
}
