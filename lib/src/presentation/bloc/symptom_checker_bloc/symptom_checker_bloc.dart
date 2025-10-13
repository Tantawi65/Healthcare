import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/models/symptom_request.dart';
import '../../../services/api_service.dart';
import 'symptom_checker_event.dart';
import 'symptom_checker_state.dart';

class SymptomCheckerBloc
    extends Bloc<SymptomCheckerEvent, SymptomCheckerState> {
  final ApiService _apiService;

  SymptomCheckerBloc({required ApiService apiService})
    : _apiService = apiService,
      super(SymptomCheckerInitial()) {
    on<CheckSymptomsButtonPressed>(_onCheckSymptomsButtonPressed);
    on<ResetSymptomChecker>(_onResetSymptomChecker);
  }

  Future<void> _onCheckSymptomsButtonPressed(
    CheckSymptomsButtonPressed event,
    Emitter<SymptomCheckerState> emit,
  ) async {
    emit(SymptomCheckerLoading());

    try {
      final request = SymptomRequest(symptomsText: event.symptomsText);
      final response = await _apiService.checkSymptoms(request);
      emit(SymptomCheckerSuccess(response.analysis));
    } catch (e) {
      emit(SymptomCheckerFailure(e.toString()));
    }
  }

  void _onResetSymptomChecker(
    ResetSymptomChecker event,
    Emitter<SymptomCheckerState> emit,
  ) {
    emit(SymptomCheckerInitial());
  }
}
