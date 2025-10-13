import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/models/symptom.dart';
import '../../../domain/repositories/symptom_repository.dart';
import 'symptom_checker_event.dart';
import 'symptom_checker_state.dart';

class SymptomCheckerBloc
    extends Bloc<SymptomCheckerEvent, SymptomCheckerState> {
  final SymptomRepository _repository;
  List<Symptom> _availableSymptoms = [];
  final List<Symptom> _selectedSymptoms = [];

  SymptomCheckerBloc(this._repository) : super(SymptomCheckerInitial()) {
    on<LoadSymptoms>(_onLoadSymptoms);
    on<SelectSymptom>(_onSelectSymptom);
    on<UnselectSymptom>(_onUnselectSymptom);
    on<AnalyzeSymptoms>(_onAnalyzeSymptoms);
    on<SaveSymptoms>(_onSaveSymptoms);
    on<LoadSymptomHistory>(_onLoadSymptomHistory);
  }

  Future<void> _onLoadSymptoms(
    LoadSymptoms event,
    Emitter<SymptomCheckerState> emit,
  ) async {
    try {
      emit(SymptomCheckerLoading());
      _availableSymptoms = await _repository.getAvailableSymptoms();
      emit(
        SymptomsLoadedState(
          availableSymptoms: _availableSymptoms,
          selectedSymptoms: _selectedSymptoms,
        ),
      );
    } catch (e) {
      emit(SymptomCheckerError(message: e.toString()));
    }
  }

  void _onSelectSymptom(
    SelectSymptom event,
    Emitter<SymptomCheckerState> emit,
  ) {
    if (!_selectedSymptoms.contains(event.symptom)) {
      _selectedSymptoms.add(event.symptom);
      emit(
        SymptomsLoadedState(
          availableSymptoms: _availableSymptoms,
          selectedSymptoms: _selectedSymptoms,
        ),
      );
    }
  }

  void _onUnselectSymptom(
    UnselectSymptom event,
    Emitter<SymptomCheckerState> emit,
  ) {
    _selectedSymptoms.remove(event.symptom);
    emit(
      SymptomsLoadedState(
        availableSymptoms: _availableSymptoms,
        selectedSymptoms: _selectedSymptoms,
      ),
    );
  }

  Future<void> _onAnalyzeSymptoms(
    AnalyzeSymptoms event,
    Emitter<SymptomCheckerState> emit,
  ) async {
    try {
      emit(SymptomCheckerLoading());
      final possibleConditions = await _repository.analyzeSymptoms(
        event.symptoms,
      );
      emit(
        SymptomAnalysisState(
          symptoms: event.symptoms,
          possibleConditions: possibleConditions,
        ),
      );
    } catch (e) {
      emit(SymptomCheckerError(message: e.toString()));
    }
  }

  Future<void> _onSaveSymptoms(
    SaveSymptoms event,
    Emitter<SymptomCheckerState> emit,
  ) async {
    try {
      await _repository.saveUserSymptoms(event.symptoms);
    } catch (e) {
      emit(SymptomCheckerError(message: e.toString()));
    }
  }

  Future<void> _onLoadSymptomHistory(
    LoadSymptomHistory event,
    Emitter<SymptomCheckerState> emit,
  ) async {
    try {
      emit(SymptomCheckerLoading());
      final symptoms = await _repository.getUserSymptomHistory();
      emit(
        SymptomsLoadedState(
          availableSymptoms: _availableSymptoms,
          selectedSymptoms: symptoms,
        ),
      );
    } catch (e) {
      emit(SymptomCheckerError(message: e.toString()));
    }
  }
}
