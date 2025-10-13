import 'package:equatable/equatable.dart';
import '../../../domain/models/symptom_response.dart';

abstract class SymptomCheckerState extends Equatable {
  const SymptomCheckerState();

  @override
  List<Object?> get props => [];
}

class SymptomCheckerInitial extends SymptomCheckerState {}

class SymptomCheckerLoading extends SymptomCheckerState {}

class SymptomCheckerSuccess extends SymptomCheckerState {
  final SymptomAnalysis analysis;

  const SymptomCheckerSuccess(this.analysis);

  @override
  List<Object?> get props => [analysis];
}

class SymptomCheckerFailure extends SymptomCheckerState {
  final String error;

  const SymptomCheckerFailure(this.error);

  @override
  List<Object?> get props => [error];
}
