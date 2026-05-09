class DetectionResult {
  final String detectionId;
  final bool isAuthentic;
  final double confidence;
  final String currency;
  final String? denomination;
  final double? denominationConfidence;
  final double processingTimeMs;
  final DateTime timestamp;

  DetectionResult({
    required this.detectionId,
    required this.isAuthentic,
    required this.confidence,
    required this.currency,
    this.denomination,
    this.denominationConfidence,
    required this.processingTimeMs,
    required this.timestamp,
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      detectionId: (json['detection_id'] ?? json['id'] ?? '').toString(),
      // Gère le booléen ou l'entier (0/1) venant de la DB
      isAuthentic: json['is_authentic'] == true || json['is_authentic'] == 1,
      confidence: (json['confidence'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'INR',
      denomination: json['denomination']?.toString(),
      denominationConfidence: (json['denomination_confidence'] ?? 0).toDouble(),
      processingTimeMs: (json['processing_time_ms'] ?? 0).toDouble(),
      timestamp: DateTime.parse(
        json['timestamp'] ?? 
        json['created_at'] ?? 
        DateTime.now().toIso8601String()
      ),
    );
  }
}