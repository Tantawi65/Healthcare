import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'symptom.g.dart';

@JsonSerializable()
class Symptom extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;

  const Symptom({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
  });

  factory Symptom.fromJson(Map<String, dynamic> json) =>
      _$SymptomFromJson(json);
  Map<String, dynamic> toJson() => _$SymptomToJson(this);

  @override
  List<Object?> get props => [id, name, description, category];
}
