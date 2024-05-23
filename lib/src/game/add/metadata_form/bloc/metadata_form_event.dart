part of 'metadata_form_bloc.dart';

sealed class MetadataFormEvent extends Equatable {
  const MetadataFormEvent();

  @override
  List<Object> get props => [];
}

final class FormSubmitted extends MetadataFormEvent {}

final class EngineChanged extends MetadataFormEvent {
  const EngineChanged({required this.engine});

  final GameEngineModel? engine;

  @override
  List<Object> get props => [];
}

final class ExePathChanged extends MetadataFormEvent {
  const ExePathChanged({required this.exePath});

  final String exePath;

  @override
  List<Object> get props => [exePath];
}

final class SavePathChanged extends MetadataFormEvent {
  const SavePathChanged({required this.savePath});

  final String savePath;

  @override
  List<Object> get props => [savePath];
}
