import 'package:equatable/equatable.dart';

abstract class SymptomCheckerEvent extends Equatable {
  const SymptomCheckerEvent();

  @override
  List<Object?> get props => [];
}

class CheckSymptomsButtonPressed extends SymptomCheckerEvent {
  final String symptomsText;

  const CheckSymptomsButtonPressed(this.symptomsText);

  @override
  List<Object?> get props => [symptomsText];
}

class ResetSymptomChecker extends SymptomCheckerEvent {}
