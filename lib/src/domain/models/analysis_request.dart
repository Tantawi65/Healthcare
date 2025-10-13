import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'analysis_request.g.dart';

@JsonSerializable()
class AnalysisRequest extends Equatable {
  final List<AnalysisParameter> parameters;

  const AnalysisRequest({required this.parameters});

  factory AnalysisRequest.fromJson(Map<String, dynamic> json) =>
      _$AnalysisRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisRequestToJson(this);

  @override
  List<Object?> get props => [parameters];
}

@JsonSerializable()
class AnalysisParameter extends Equatable {
  final String name;
  final double value;
  final String unit;

  const AnalysisParameter({
    required this.name,
    required this.value,
    required this.unit,
  });

  factory AnalysisParameter.fromJson(Map<String, dynamic> json) =>
      _$AnalysisParameterFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisParameterToJson(this);

  @override
  List<Object?> get props => [name, value, unit];
}
