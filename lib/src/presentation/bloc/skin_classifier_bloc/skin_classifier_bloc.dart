import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/api_service.dart';
import 'skin_classifier_event.dart';
import 'skin_classifier_state.dart';

class SkinClassifierBloc
    extends Bloc<SkinClassifierEvent, SkinClassifierState> {
  final ApiService _apiService;

  SkinClassifierBloc({required ApiService apiService})
    : _apiService = apiService,
      super(SkinClassifierInitial()) {
    on<ClassifySkinImageEvent>(_onClassifySkinImageEvent);
    on<ResetSkinClassifierEvent>(_onResetSkinClassifierEvent);
  }

  Future<void> _onClassifySkinImageEvent(
    ClassifySkinImageEvent event,
    Emitter<SkinClassifierState> emit,
  ) async {
    emit(SkinClassifierLoading());

    try {
      final response = await _apiService.classifySkinImage(event.request);
      // response.predictions is List<SkinPrediction>
      emit(SkinClassifierSuccess(response.predictions));
    } catch (e) {
      emit(SkinClassifierFailure(e.toString()));
    }
  }

  void _onResetSkinClassifierEvent(
    ResetSkinClassifierEvent event,
    Emitter<SkinClassifierState> emit,
  ) {
    emit(SkinClassifierInitial());
  }
}
