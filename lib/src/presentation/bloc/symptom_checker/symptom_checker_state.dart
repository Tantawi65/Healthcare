import 'package:equatable/equatable.dart';
import '../../../domain/models/symptom.dart';

abstract class SymptomCheckerState extends Equatable {
  const SymptomCheckerState();

  @override
  List<Object?> get props => [];
}

class SymptomCheckerInitial extends SymptomCheckerState {}

class SymptomCheckerLoading extends SymptomCheckerState {}

class SymptomsLoadedState extends SymptomCheckerState {
  final List<Symptom> availableSymptoms;
  final List<Symptom> selectedSymptoms;

  const SymptomsLoadedState({
    required this.availableSymptoms,
    required this.selectedSymptoms,
  });

  @override
  List<Object?> get props => [availableSymptoms, selectedSymptoms];
}

class SymptomAnalysisState extends SymptomCheckerState {
  final List<Symptom> symptoms;
  final Map<String, double> possibleConditions;

  const SymptomAnalysisState({
    required this.symptoms,
    required this.possibleConditions,
  });

  @override
  List<Object?> get props => [symptoms, possibleConditions];
}

class SymptomCheckerError extends SymptomCheckerState {
  final String message;

  const SymptomCheckerError({required this.message});

  @override
  List<Object?> get props => [message];
}