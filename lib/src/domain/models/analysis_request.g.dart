// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalysisRequest _$AnalysisRequestFromJson(Map<String, dynamic> json) =>
    AnalysisRequest(
      parameters: (json['parameters'] as List<dynamic>)
          .map((e) => AnalysisParameter.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AnalysisRequestToJson(AnalysisRequest instance) =>
    <String, dynamic>{'parameters': instance.parameters};

AnalysisParameter _$AnalysisParameterFromJson(Map<String, dynamic> json) =>
    AnalysisParameter(
      name: json['name'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
    );

Map<String, dynamic> _$AnalysisParameterToJson(AnalysisParameter instance) =>
    <String, dynamic>{
      'name': instance.name,
      'value': instance.value,
      'unit': instance.unit,
    };
