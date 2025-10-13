import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'analysis_response.g.dart';

@JsonSerializable()
class AnalysisResponse extends Equatable {
  final List<AnalysisResult> analysis;

  const AnalysisResponse({required this.analysis});

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) =>
      _$AnalysisResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisResponseToJson(this);

  @override
  List<Object?> get props => [analysis];
}

@JsonSerializable()
class AnalysisResult extends Equatable {
  final String name;
  final double value;
  final String unit;
  final String status;
  final String range;

  const AnalysisResult({
    required this.name,
    required this.value,
    required this.unit,
    required this.status,
    required this.range,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) =>
      _$AnalysisResultFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisResultToJson(this);

  @override
  List<Object?> get props => [name, value, unit, status, range];
}
