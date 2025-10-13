import 'package:json_annotation/json_annotation.dart';

part 'skin_response.g.dart';

@JsonSerializable()
class SkinPrediction {
  final String condition;
  final double confidence;

  SkinPrediction({required this.condition, required this.confidence});

  factory SkinPrediction.fromJson(Map<String, dynamic> json) =>
      _$SkinPredictionFromJson(json);
  Map<String, dynamic> toJson() => _$SkinPredictionToJson(this);
}

@JsonSerializable()
class SkinResponse {
  final List<SkinPrediction> predictions;

  SkinResponse({required this.predictions});

  factory SkinResponse.fromJson(Map<String, dynamic> json) =>
      _$SkinResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SkinResponseToJson(this);
}
