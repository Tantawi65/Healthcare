import 'package:equatable/equatable.dart';
import '../../../domain/models/analysis_response.dart';

abstract class LabAnalysisState extends Equatable {
  const LabAnalysisState();

  @override
  List<Object?> get props => [];
}

class LabAnalysisInitial extends LabAnalysisState {}

class LabAnalysisLoading extends LabAnalysisState {}

class LabAnalysisSuccess extends LabAnalysisState {
  final AnalysisResponse response;

  const LabAnalysisSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

class LabAnalysisFailure extends LabAnalysisState {
  final String error;

  const LabAnalysisFailure(this.error);

  @override
  List<Object?> get props => [error];
}
