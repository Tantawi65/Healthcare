// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skin_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SkinPrediction _$SkinPredictionFromJson(Map<String, dynamic> json) =>
    SkinPrediction(
      condition: json['condition'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );

Map<String, dynamic> _$SkinPredictionToJson(SkinPrediction instance) =>
    <String, dynamic>{
      'condition': instance.condition,
      'confidence': instance.confidence,
    };

SkinResponse _$SkinResponseFromJson(Map<String, dynamic> json) => SkinResponse(
  predictions: (json['predictions'] as List<dynamic>)
      .map((e) => SkinPrediction.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SkinResponseToJson(SkinResponse instance) =>
    <String, dynamic>{'predictions': instance.predictions};
