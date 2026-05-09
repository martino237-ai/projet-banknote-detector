import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/detection_result.dart';

class ApiService extends ChangeNotifier {
  // 🛰 CONFIGURATION DE L'URL
  // localhost (127.0.0.1) est impératif pour le Web pour éviter les blocages de sécurité
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:5000';
    }
    // Pour mobile (Android Emulator = 10.0.2.2, Physique = ton IP)
    return 'http://192.168.1.227:5000';
  }
  
  bool _isLoading = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<DetectionResult?> detectImage(XFile imageFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    final url = '$baseUrl/api/detect';
    debugPrint('🌐 Appel API: $url');
    
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      
      final bytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.name,
        ),
      );
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      debugPrint('📥 Réponse status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(responseBody);
        return DetectionResult.fromJson(jsonData);
      } else {
        _error = 'Erreur serveur (${response.statusCode})';
        return null;
      }
    } catch (e) {
      _error = 'Échec de la connexion. Vérifiez que Flask est lancé sur $baseUrl';
      debugPrint('❌ Erreur réseau: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<DetectionResult>> getHistory() async {
    final url = '$baseUrl/api/history';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((item) => DetectionResult.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Erreur historique: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getStats() async {
    final url = '$baseUrl/api/stats';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Erreur stats: $e');
      return null;
    }
  }
}
