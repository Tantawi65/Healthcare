// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'symptom_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SymptomResponse _$SymptomResponseFromJson(Map<String, dynamic> json) =>
    SymptomResponse(
      analysis: SymptomAnalysis.fromJson(
        json['analysis'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$SymptomResponseToJson(SymptomResponse instance) =>
    <String, dynamic>{'analysis': instance.analysis};

SymptomAnalysis _$SymptomAnalysisFromJson(Map<String, dynamic> json) =>
    SymptomAnalysis(
      potentialConditions: (json['potential_conditions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendation: json['recommendation'] as String,
      urgency: json['urgency'] as String,
    );

Map<String, dynamic> _$SymptomAnalysisToJson(SymptomAnalysis instance) =>
    <String, dynamic>{
      'potential_conditions': instance.potentialConditions,
      'recommendation': instance.recommendation,
      'urgency': instance.urgency,
    };
