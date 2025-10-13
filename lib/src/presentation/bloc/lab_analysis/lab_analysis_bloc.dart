import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gp_tea/services/api_service.dart';
import 'lab_analysis_event.dart';
import 'lab_analysis_state.dart';

class LabAnalysisBloc extends Bloc<LabAnalysisEvent, LabAnalysisState> {
  final ApiService _apiService;

  LabAnalysisBloc({required ApiService apiService})
    : _apiService = apiService,
      super(LabAnalysisInitial()) {
    on<AnalyzeButtonPressed>(_onAnalyzeButtonPressed);
    on<ResetLabAnalysis>(_onResetLabAnalysis);
  }

  Future<void> _onAnalyzeButtonPressed(
    AnalyzeButtonPressed event,
    Emitter<LabAnalysisState> emit,
  ) async {
    // 1. Emit loading state
    emit(LabAnalysisLoading());

    try {
      // 2. Call the API service
      final response = await _apiService.analyzeReport(event.request);

      // 3. Emit success state with results
      emit(LabAnalysisSuccess(response));
    } on ApiException catch (e) {
      // 4. Handle API-specific errors
      emit(LabAnalysisFailure(e.message));
    } catch (e) {
      // 5. Handle unexpected errors
      emit(LabAnalysisFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }

  void _onResetLabAnalysis(
    ResetLabAnalysis event,
    Emitter<LabAnalysisState> emit,
  ) {
    emit(LabAnalysisInitial());
  }
}
