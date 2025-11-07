import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class Version {
  final List<int> parts;
  
  Version(this.parts);
  
  factory Version.parse(String version) {
    return Version(version.split('.').map(int.parse).toList());
  }
  
  bool operator >(Version other) {
    for (var i = 0; i < parts.length; i++) {
      if (parts[i] > other.parts[i]) return true;
      if (parts[i] < other.parts[i]) return false;
    }
    return false;
  }
}

class UpdateScreen extends ConsumerStatefulWidget {
  const UpdateScreen({super.key});

  @override
  ConsumerState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends ConsumerState<UpdateScreen> {
  String currentVersion = '';
  String latestVersion = '';
  bool isLoading = true;
  bool updateAvailable = false;

  @override
  void initState() {
    super.initState();
    checkForUpdates();
  }

  Future<void> checkForUpdates() async {
    try {
      // Obtenir la version actuelle
      final packageInfo = await PackageInfo.fromPlatform();
      String currentVersionRaw = packageInfo.version;
      Version current = Version.parse(currentVersionRaw);

      // Obtenir la dernière version depuis GitHub
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/Daris02/social-app-ui/releases/latest'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String latestVersionRaw = data['tag_name'].replaceAll('v', '');
        Version latest = Version.parse(latestVersionRaw);

        setState(() {
          currentVersion = currentVersionRaw;
          latestVersion = latestVersionRaw;
          updateAvailable = latest > current;
          isLoading = false;
        });
      } else {
        setState(() {
          latestVersion = 'Erreur de vérification';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        latestVersion = 'Erreur: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mise à jour'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Version actuelle: $currentVersion',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Dernière version: $latestVersion',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 30),
                  if (updateAvailable) ...[
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Ouvrir le lien des releases
                          // Vous pouvez utiliser url_launcher package pour ouvrir le navigateur
                        },
                        child: const Text('Télécharger la mise à jour'),
                      ),
                    ),
                  ] else
                    const Center(
                      child: Text(
                        'Votre application est à jour !',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}