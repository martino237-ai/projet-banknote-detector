import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _urlController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadUrl();
  }
  
  Future<void> _loadUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('api_url') ?? 'http://192.168.1.227:5000';
    _urlController.text = url;
  }
  
  Future<void> _saveUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_url', _urlController.text);
    
    // Mettre à jour l'API service
    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService.setBaseUrl(_urlController.text);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuration sauvegardée')),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration API'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL de l\'API',
                border: OutlineInputBorder(),
                hintText: 'http://192.168.1.227:5000',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveUrl,
              child: const Text('Sauvegarder'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Exemples:\n'
              '- http://localhost:5000 (même PC)\n'
              '- http://10.0.2.2:5000 (émulateur)\n'
              '- http://192.168.1.X:5000 (téléphone)',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}