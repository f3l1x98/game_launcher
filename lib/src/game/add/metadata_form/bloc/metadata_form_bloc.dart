import 'package:bloc/bloc.dart';
import 'package:database_repository/database_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:game_launcher/src/game/add/metadata_form/models/engine.dart';
import 'package:game_launcher/src/game/add/metadata_form/models/exe_path.dart';
import 'package:game_launcher/src/game/add/metadata_form/models/save_path.dart';

part 'metadata_form_event.dart';
part 'metadata_form_state.dart';

class MetadataFormBloc extends Bloc<MetadataFormEvent, MetadataFormState> {
  MetadataFormBloc({
    required GameDatabaseRepository gameDatabaseRepository,
    required GameEngineRepository gameEngineRepository,
  })  : _gameDatabaseRepository = gameDatabaseRepository,
        _gameEngineRepository = gameEngineRepository,
        super(MetadataFormState(
          gameEngines: gameEngineRepository.getAllGameEngines(),
          /*engine: Engine.dirty(
            gameEngineRepository.getGameEngine(
                gameDatabaseRepository.creationGame.usedGameEngineEnum),
          ),
          exePath: ExePath.dirty(gameDatabaseRepository.creationGame.exePath),
          savePath: SavePath.dirty(gameDatabaseRepository.creationGame.savesPath),
          isValid: */
        )) {
    on<EngineChanged>(_onEngineChanged);
    on<ExePathChanged>(_onExePathChanged);
    on<SavePathChanged>(_onSavePathChanged);
    on<FormSubmitted>(_onFormSubmitted);

    add(EngineChanged(
      engine: gameEngineRepository.getGameEngine(
          gameDatabaseRepository.creationGame.usedGameEngineEnum),
    ));
    add(ExePathChanged(exePath: gameDatabaseRepository.creationGame.exePath));
    if (gameDatabaseRepository.creationGame.savesPath != null) {
      add(SavePathChanged(
          savePath: gameDatabaseRepository.creationGame.savesPath!));
    }
  }

  final GameDatabaseRepository _gameDatabaseRepository;
  final GameEngineRepository _gameEngineRepository;

  _onEngineChanged(
    EngineChanged event,
    Emitter<MetadataFormState> emit,
  ) {
    final engine = Engine.dirty(event.engine);
    emit(state.copyWith(
      engine: engine,
      isValid: _validateWithState(engine: engine),
    ));
  }

  bool _validateWithState({
    Engine? engine,
    ExePath? exePath,
    SavePath? savePath,
  }) {
    return Formz.validate([
      engine ?? state.engine,
      exePath ?? state.exePath,
      savePath ?? state.savePath,
    ]);
  }

  _onExePathChanged(
    ExePathChanged event,
    Emitter<MetadataFormState> emit,
  ) {
    final exePath = ExePath.dirty(event.exePath);
    emit(state.copyWith(
      exePath: exePath,
      isValid: _validateWithState(exePath: exePath),
    ));
  }

  _onSavePathChanged(
    SavePathChanged event,
    Emitter<MetadataFormState> emit,
  ) {
    final savePath = SavePath.dirty(event.savePath);
    emit(state.copyWith(
      savePath: savePath,
      isValid: _validateWithState(savePath: savePath),
    ));
  }

  _onFormSubmitted(
    FormSubmitted event,
    Emitter<MetadataFormState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      try {
        // Using ! is save due to these attributes being required
        // and thus triggering validation error -> state.isValid == false
        _gameDatabaseRepository.updateMetadataForm(
          gameEngineEnum: state.engine.value!.gameEngineEnum,
          absoluteExePath: state.exePath.value!,
          absoluteSavesPath: state.savePath.value,
        );
        emit(state.copyWith(status: FormzSubmissionStatus.success));
      } catch (_) {
        emit(state.copyWith(status: FormzSubmissionStatus.failure));
      }
    }
  }
}
