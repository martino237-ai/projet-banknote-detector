import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/detection_result.dart';

class HistoryService extends ChangeNotifier {
  List<DetectionResult> _history = [];
  static const String _storageKey = 'detection_history';

  List<DetectionResult> get history => List.unmodifiable(_history);

  HistoryService() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString(_storageKey);
      
      if (historyJson != null) {
        final List<dynamic> decoded = json.decode(historyJson);
        // Note: Il faudra peut-être adapter DetectionResult pour inclure un mécanisme de sérialisation JSON inverse
        // Mais pour l'instant, on gère la liste en mémoire
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement de l\'historique: $e');
    }
  }

  Future<void> addResult(DetectionResult result) async {
    _history.insert(0, result); // Ajouter au début
    notifyListeners();
    // TODO: Persister dans SharedPreferences
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}