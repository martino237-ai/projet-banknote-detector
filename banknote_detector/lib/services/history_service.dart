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
        _history = decoded
            .cast<Map<String, dynamic>>()
            .map(DetectionResult.fromJson)
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement de l\'historique: $e');
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String historyJson = json.encode(_history.map((r) => r.toJson()).toList());
      await prefs.setString(_storageKey, historyJson);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde de l\'historique: $e');
    }
  }

  Future<void> refreshHistory() async {
    await _loadHistory();
  }

  Future<void> addResult(DetectionResult result) async {
    _history.insert(0, result); // Ajouter au début
    notifyListeners();
    await _saveHistory();
  }

  Future<void> clearHistory() async {
    _history.clear();
    notifyListeners();
    await _saveHistory();
  }
}