// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'symptom.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Symptom _$SymptomFromJson(Map<String, dynamic> json) => Symptom(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  category: json['category'] as String,
);

Map<String, dynamic> _$SymptomToJson(Symptom instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'category': instance.category,
};
