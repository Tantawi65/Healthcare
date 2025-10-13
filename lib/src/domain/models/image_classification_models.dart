// Image Classification Models
class ImagePrediction {
  final String label;
  final double confidence;
  final String confidencePercent;

  ImagePrediction({
    required this.label,
    required this.confidence,
    required this.confidencePercent,
  });

  factory ImagePrediction.fromJson(Map<String, dynamic> json) {
    return ImagePrediction(
      label: json['label'] ?? '',
      confidence: (json['confidence'] as num).toDouble(),
      confidencePercent: json['confidence_percent'] ?? '0.00%',
    );
  }
}

class ImageClassificationResult {
  final ImagePrediction topPrediction;
  final List<ImagePrediction> allPredictions;

  ImageClassificationResult({
    required this.topPrediction,
    required this.allPredictions,
  });

  factory ImageClassificationResult.fromJson(Map<String, dynamic> json) {
    final prediction = json['prediction'];
    return ImageClassificationResult(
      topPrediction: ImagePrediction.fromJson(prediction['top_prediction']),
      allPredictions: (prediction['all_predictions'] as List)
          .map((pred) => ImagePrediction.fromJson(pred))
          .toList(),
    );
  }
}

class ImageClassificationResponse {
  final bool success;
  final ImageClassificationResult? prediction;
  final String? error;

  ImageClassificationResponse({
    required this.success,
    this.prediction,
    this.error,
  });

  factory ImageClassificationResponse.fromJson(Map<String, dynamic> json) {
    return ImageClassificationResponse(
      success: json['success'] ?? false,
      prediction: json['prediction'] != null
          ? ImageClassificationResult.fromJson(json)
          : null,
      error: json['error'],
    );
  }
}