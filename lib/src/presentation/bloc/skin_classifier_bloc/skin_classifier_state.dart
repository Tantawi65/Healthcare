import 'package:equatable/equatable.dart';
import '../../../domain/models/skin_response.dart';

abstract class SkinClassifierState extends Equatable {
  const SkinClassifierState();

  @override
  List<Object?> get props => [];
}

class SkinClassifierInitial extends SkinClassifierState {}

class SkinClassifierLoading extends SkinClassifierState {}

class SkinClassifierSuccess extends SkinClassifierState {
  final List<SkinPrediction> predictions;

  const SkinClassifierSuccess(this.predictions);

  @override
  List<Object?> get props => [predictions];
}

class SkinClassifierFailure extends SkinClassifierState {
  final String error;

  const SkinClassifierFailure(this.error);

  @override
  List<Object?> get props => [error];
}
