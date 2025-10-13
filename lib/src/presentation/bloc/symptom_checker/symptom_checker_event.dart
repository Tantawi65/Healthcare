import 'package:equatable/equatable.dart';
import '../../../domain/models/symptom.dart';

abstract class SymptomCheckerEvent extends Equatable {
  const SymptomCheckerEvent();

  @override
  List<Object?> get props => [];
}

class LoadSymptoms extends SymptomCheckerEvent {}

class SelectSymptom extends SymptomCheckerEvent {
  final Symptom symptom;

  const SelectSymptom(this.symptom);

  @override
  List<Object?> get props => [symptom];
}

class UnselectSymptom extends SymptomCheckerEvent {
  final Symptom symptom;

  const UnselectSymptom(this.symptom);

  @override
  List<Object?> get props => [symptom];
}

class AnalyzeSymptoms extends SymptomCheckerEvent {
  final List<Symptom> symptoms;

  const AnalyzeSymptoms(this.symptoms);

  @override
  List<Object?> get props => [symptoms];
}

class SaveSymptoms extends SymptomCheckerEvent {
  final List<Symptom> symptoms;

  const SaveSymptoms(this.symptoms);

  @override
  List<Object?> get props => [symptoms];
}

class LoadSymptomHistory extends SymptomCheckerEvent {}