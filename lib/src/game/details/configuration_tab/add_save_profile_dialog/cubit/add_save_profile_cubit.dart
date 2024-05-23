import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:database_repository/database_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:files_repository/files_repository.dart';
import 'package:formz/formz.dart';
import 'package:game_launcher/src/extensions/file_system_extensions.dart';
import 'package:game_launcher/src/game/details/configuration_tab/add_save_profile_dialog/models/copy_current.dart';
import 'package:game_launcher/src/game/details/configuration_tab/add_save_profile_dialog/models/save_profile_name.dart';
import 'package:path/path.dart' as p;

part 'add_save_profile_state.dart';

class AddSaveProfileCubit extends Cubit<AddSaveProfileState> {
  AddSaveProfileCubit({
    required GameModel game,
    required List<String> saveProfileNames,
    required GameDatabaseRepository gameDatabaseRepository,
    required GameEngineRepository gameEngineRepository,
    required SaveProfileDatabaseRepository saveProfileRepository,
    required FilesRepository filesRepository,
  })  : _game = game,
        _saveProfileNames = saveProfileNames,
        _gameDatabaseRepository = gameDatabaseRepository,
        _gameEngineRepository = gameEngineRepository,
        _saveProfileRepository = saveProfileRepository,
        _filesRepository = filesRepository,
        super(AddSaveProfileState());

  final GameModel _game;
  final List<String> _saveProfileNames;
  final GameDatabaseRepository _gameDatabaseRepository;
  final GameEngineRepository _gameEngineRepository;
  final SaveProfileDatabaseRepository _saveProfileRepository;
  final FilesRepository _filesRepository;

  updateSaveProfileName({required String? value}) {
    final saveProfileName = SaveProfileName.dirty(
      saveProfileNames: _saveProfileNames,
      value: value,
    );
    emit(state.copyWith(
      saveProfileName: saveProfileName,
      isValid: _validateWithState(saveProfileName: saveProfileName),
    ));
  }

  bool _validateWithState({
    SaveProfileName? saveProfileName,
    CopyCurrent? copyCurrentSave,
  }) {
    return Formz.validate([
      saveProfileName ?? state.saveProfileName,
      copyCurrentSave ?? state.copyCurrentSave,
    ]);
  }

  updateCopyCurrent({required bool value}) {
    final copyCurrentSave = CopyCurrent.dirty(value);
    emit(state.copyWith(
      copyCurrentSave: copyCurrentSave,
      isValid: _validateWithState(copyCurrentSave: copyCurrentSave),
    ));
  }

  Future<void> createSaveProfile() async {
    if (_game.savesPath == null) {
      // TODO error, because this should never happen
      return;
    }

    SaveProfileModel newSaveProfile =
        await _saveProfileRepository.insert(SaveProfileModel.create(
      name: state.saveProfileName.value!,
      gameId: _game.id,
      active: false,
      gameVersion: _game.version,
    ));
    final profileDirectory = _filesRepository.getDirectory(p.join(
      _game.metadataPath,
      FilesRepository.saveProfileDirectoryName,
      newSaveProfile.profileDirectoryName,
    ));
    await profileDirectory.create(recursive: true);

    _game.saveProfileIds.add(newSaveProfile.id);
    await _gameDatabaseRepository.update(_game);

    // Copy current save
    if (state.copyCurrentSave.value) {
      await _copySaveFilesToProfile(
        gameEngine:
            _gameEngineRepository.getGameEngine(_game.usedGameEngineEnum),
        savesDirectory: _filesRepository.getDirectory(_game.savesPath!),
        newProfileDirectory: profileDirectory,
      );
    }
  }

  Future<void> _copySaveFilesToProfile({
    required GameEngineModel gameEngine,
    required Directory savesDirectory,
    required Directory newProfileDirectory,
  }) async {
    // Check whether saves dir exists -> if not skip
    if (!(await savesDirectory.exists())) {
      return;
    }
    // Get all save files from saves dir (because it could contain other files/dirs as well)
    final saveFiles = (await savesDirectory.list().toList())
        .where((entity) => gameEngine.saveFileExtensions.isEmpty
            ? true
            : gameEngine.saveFileExtensions.contains(p.extension(entity.path)))
        .toList();

    List<Future<FileSystemEntity>> copyFutures = [];
    for (var saveFile in saveFiles) {
      saveFile.copy(
        p.join(
          newProfileDirectory.absolute.path,
          p.basename(saveFile.path),
        ),
        recursive: true,
      );
    }
    await Future.wait(copyFutures);
  }
}
