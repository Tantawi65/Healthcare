import 'package:equatable/equatable.dart';
import '../../../domain/models/skin_request.dart';

abstract class SkinClassifierEvent extends Equatable {
  const SkinClassifierEvent();

  @override
  List<Object?> get props => [];
}

class ClassifySkinImageEvent extends SkinClassifierEvent {
  final SkinRequest request;

  const ClassifySkinImageEvent(this.request);

  @override
  List<Object?> get props => [request];
}

class ResetSkinClassifierEvent extends SkinClassifierEvent {}
