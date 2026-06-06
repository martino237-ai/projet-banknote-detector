import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/detection_result.dart';

class ApiService extends ChangeNotifier {
  // CONFIGURATION DYNAMIQUE
  static String _baseUrl = kIsWeb ? 'http://127.0.0.1:5000' : 'http://10.0.2.2:5000';

  static String get baseUrl => _baseUrl;
  void setBaseUrl(String url) {
    _baseUrl = url;
    notifyListeners();
  }
  
  bool _isLoading = false;
  String? _error;
  bool _isServerAvailable = true;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isServerAvailable => _isServerAvailable;
  
  /// Vérifie si le serveur est en ligne
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/health'))
          .timeout(const Duration(seconds: 3));
      _isServerAvailable = response.statusCode == 200;
      notifyListeners();
      return _isServerAvailable;
    } catch (_) {
      _isServerAvailable = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Analyse l'image avec gestion d'erreurs avancée
  Future<DetectionResult?> detectImage(XFile imageFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final url = Uri.parse('$baseUrl/api/detect');
      var request = http.MultipartRequest('POST', url);
      
      final bytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );
      
      // Ajout d'un timeout pour plus de fiabilité
      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        _isServerAvailable = true;
        return DetectionResult.fromJson(jsonData);
      } else {
        _error = 'Le serveur a renvoyé une erreur (${response.statusCode})';
        return null;
      }
    } on SocketException {
      _error = 'Impossible de contacter le serveur. Vérifiez que Flask est lancé sur $baseUrl';
      _isServerAvailable = false;
    } on HttpException {
      _error = 'Erreur lors de la communication avec le serveur.';
    } on FormatException {
      _error = 'Réponse du serveur invalide.';
    } catch (e) {
      _error = 'Une erreur inattendue est survenue : $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  Future<List<DetectionResult>> getHistory() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/history'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((item) => DetectionResult.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Erreur historique: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> getStats() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/stats'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Erreur stats: $e');
    }
    return null;
  }
}
