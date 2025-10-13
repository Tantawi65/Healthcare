import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'symptom_request.g.dart';

@JsonSerializable()
class SymptomRequest {
  @JsonKey(name: 'symptoms_text')
  final String symptomsText;

  const SymptomRequest({required this.symptomsText});

  factory SymptomRequest.fromJson(Map<String, dynamic> json) =>
      _$SymptomRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SymptomRequestToJson(this);

  @override
  String toString() => 'SymptomRequest(symptomsText: $symptomsText)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SymptomRequest && other.symptomsText == symptomsText;
  }

  @override
  int get hashCode => symptomsText.hashCode;
}
