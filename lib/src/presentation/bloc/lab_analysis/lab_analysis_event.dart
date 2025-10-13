import 'package:equatable/equatable.dart';
import '../../../domain/models/analysis_request.dart';

abstract class LabAnalysisEvent extends Equatable {
  const LabAnalysisEvent();

  @override
  List<Object?> get props => [];
}

class AnalyzeButtonPressed extends LabAnalysisEvent {
  final AnalysisRequest request;

  const AnalyzeButtonPressed(this.request);

  @override
  List<Object?> get props => [request];
}

class ResetLabAnalysis extends LabAnalysisEvent {}
