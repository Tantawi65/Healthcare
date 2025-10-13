import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'symptom_response.g.dart';

@JsonSerializable()
class SymptomResponse {
  @JsonKey(name: 'analysis')
  final SymptomAnalysis analysis;

  const SymptomResponse({required this.analysis});

  factory SymptomResponse.fromJson(Map<String, dynamic> json) =>
      _$SymptomResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SymptomResponseToJson(this);

  @override
  String toString() => 'SymptomResponse(analysis: $analysis)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SymptomResponse && other.analysis == analysis;
  }

  @override
  int get hashCode => analysis.hashCode;
}

@JsonSerializable()
class SymptomAnalysis {
  @JsonKey(name: 'potential_conditions')
  final List<String> potentialConditions;
  final String recommendation;
  final String urgency;

  const SymptomAnalysis({
    required this.potentialConditions,
    required this.recommendation,
    required this.urgency,
  });

  factory SymptomAnalysis.fromJson(Map<String, dynamic> json) =>
      _$SymptomAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$SymptomAnalysisToJson(this);

  @override
  String toString() =>
      'SymptomAnalysis(potentialConditions: $potentialConditions, recommendation: $recommendation, urgency: $urgency)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SymptomAnalysis &&
        other.recommendation == recommendation &&
        other.urgency == urgency &&
        listEquals(other.potentialConditions, potentialConditions);
  }

  @override
  int get hashCode =>
      potentialConditions.hashCode ^ recommendation.hashCode ^ urgency.hashCode;
}

bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  if (identical(a, b)) return true;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
