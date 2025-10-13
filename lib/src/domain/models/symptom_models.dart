// Models for symptom checker API

class SymptomPrediction {
  final int rank;
  final String disease;
  final double confidence;
  final String confidencePercent;

  SymptomPrediction({
    required this.rank,
    required this.disease,
    required this.confidence,
    required this.confidencePercent,
  });

  factory SymptomPrediction.fromJson(Map<String, dynamic> json) {
    return SymptomPrediction(
      rank: json['rank'] ?? 0,
      disease: json['disease'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      confidencePercent: json['confidence_percent'] ?? '0.00%',
    );
  }
}

class SymptomCheckResponse {
  final bool success;
  final List<SymptomPrediction> predictions;
  final List<String> inputSymptoms;
  final String? error;

  SymptomCheckResponse({
    required this.success,
    required this.predictions,
    required this.inputSymptoms,
    this.error,
  });

  factory SymptomCheckResponse.fromJson(Map<String, dynamic> json) {
    return SymptomCheckResponse(
      success: json['success'] ?? false,
      predictions: json['predictions'] != null
          ? (json['predictions'] as List)
              .map((pred) => SymptomPrediction.fromJson(pred))
              .toList()
          : [],
      inputSymptoms: json['input_symptoms'] != null
          ? List<String>.from(json['input_symptoms'])
          : [],
      error: json['error'],
    );
  }
}

class AvailableSymptoms {
  final bool success;
  final List<String> symptoms;
  final int totalSymptoms;
  final String? error;

  AvailableSymptoms({
    required this.success,
    required this.symptoms,
    required this.totalSymptoms,
    this.error,
  });

  factory AvailableSymptoms.fromJson(Map<String, dynamic> json) {
    return AvailableSymptoms(
      success: json['success'] ?? false,
      symptoms: json['symptoms'] != null
          ? List<String>.from(json['symptoms'])
          : [],
      totalSymptoms: json['total_symptoms'] ?? 0,
      error: json['error'],
    );
  }
}

class SymptomCheckRequest {
  final List<String> symptoms;

  SymptomCheckRequest({required this.symptoms});

  Map<String, dynamic> toJson() {
    return {
      'symptoms': symptoms,
    };
  }
}