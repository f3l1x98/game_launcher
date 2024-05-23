part of 'metadata_form_bloc.dart';

final class MetadataFormState extends Equatable {
  const MetadataFormState({
    this.gameEngines = const [],
    this.status = FormzSubmissionStatus.initial,
    this.engine = const Engine.pure(),
    this.exePath = const ExePath.pure(),
    this.savePath = const SavePath.pure(),
    this.isValid = false,
  });

  final List<GameEngineModel> gameEngines;

  final FormzSubmissionStatus status;
  final Engine engine;
  final ExePath exePath;
  final SavePath savePath;
  final bool isValid;

  MetadataFormState copyWith({
    List<GameEngineModel>? gameEngines,
    FormzSubmissionStatus? status,
    Engine? engine,
    ExePath? exePath,
    SavePath? savePath,
    bool? isValid,
  }) {
    return MetadataFormState(
      gameEngines: gameEngines ?? this.gameEngines,
      status: status ?? this.status,
      engine: engine ?? this.engine,
      exePath: exePath ?? this.exePath,
      savePath: savePath ?? this.savePath,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object> get props => [
        gameEngines,
        status,
        engine,
        exePath,
        savePath,
        isValid,
      ];
}
