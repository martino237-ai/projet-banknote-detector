import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/detection_result.dart';

class MockApiService extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<DetectionResult?> detectImage(XFile imageFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    // Simuler un délai réseau
    await Future.delayed(const Duration(seconds: 2));
    
    // Générer un résultat aléatoire pour tester
    final random = Random();
    final isAuthentic = random.nextBool();
    final denominations = ['10', '20', '50', '100', '200', '500', '2000'];
    
    final result = DetectionResult(
      detectionId: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      isAuthentic: isAuthentic,
      confidence: 0.7 + random.nextDouble() * 0.29,
      currency: 'INR',
      denomination: isAuthentic ? denominations[random.nextInt(denominations.length)] : null,
      denominationConfidence: isAuthentic ? 0.6 + random.nextDouble() * 0.39 : null,
      processingTimeMs: 100 + random.nextDouble() * 200,
      timestamp: DateTime.now(),
    );
    
    _isLoading = false;
    notifyListeners();
    
    return result;
  }
}