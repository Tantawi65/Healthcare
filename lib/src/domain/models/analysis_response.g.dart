// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalysisResponse _$AnalysisResponseFromJson(Map<String, dynamic> json) =>
    AnalysisResponse(
      analysis: (json['analysis'] as List<dynamic>)
          .map((e) => AnalysisResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AnalysisResponseToJson(AnalysisResponse instance) =>
    <String, dynamic>{'analysis': instance.analysis};

AnalysisResult _$AnalysisResultFromJson(Map<String, dynamic> json) =>
    AnalysisResult(
      name: json['name'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      status: json['status'] as String,
      range: json['range'] as String,
    );

Map<String, dynamic> _$AnalysisResultToJson(AnalysisResult instance) =>
    <String, dynamic>{
      'name': instance.name,
      'value': instance.value,
      'unit': instance.unit,
      'status': instance.status,
      'range': instance.range,
    };
