import 'package:flutter/material.dart';
import 'package:social_app/providers/annonce_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_app/services/auth_service.dart';
import '../services/api_service.dart';
import '../routes/app_router.dart';

class AnnoncesScreen extends ConsumerWidget {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  AnnoncesScreen({super.key});

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Nouvelle annonce"),
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
              await ApiService.createAnnonce(
                _titleController.text,
                _contentController.text,
              );
              _titleController.clear();
              _contentController.clear();
              // ignore: unused_result
              ref.refresh(annoncesProvider);
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
    final annonces = ref.watch(annoncesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text("Annonces"),
        actions: [
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () => appRouter.go('/chat'),
            tooltip: 'Chat',
          ),
          IconButton(
            icon: Icon(Icons.video_call),
            onPressed: () => appRouter.go('/call'),
            tooltip: 'Call',
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              final success = await ref.read(authProvider.notifier).logout();
              if (success) appRouter.go('/');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, ref),
        child: Icon(Icons.add),
      ),
      body: annonces.when(
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
          print("Erreur lors du chargement des annonces: $e");
          return Center(child: Text("Erreur de chargement"));
        },
      ),
    );
  }
}
