import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:database_repository/database_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:files_repository/files_repository.dart';
import 'package:game_launcher/src/extensions/file_system_extensions.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings_repository/settings_repository.dart';
import 'package:shared_kernel/shared_kernel.dart';
import 'package:path/path.dart' as p;

part 'configuration_tab_event.dart';
part 'configuration_tab_state.dart';

class ConfigurationTabBloc
    extends Bloc<ConfigurationTabEvent, ConfigurationTabState> {
  ConfigurationTabBloc({
    required GameModel game,
    required GameEngineModel gameEngine,
    required GameDatabaseRepository gameDatabaseRepository,
    required SaveProfileDatabaseRepository saveProfileDatabaseRepository,
    required FilesRepository filesRepository,
    required SettingsRepository settingsRepository,
  })  : _game = game,
        _gameEngine = gameEngine,
        _gameDatabaseRepository = gameDatabaseRepository,
        _saveProfileDatabaseRepository = saveProfileDatabaseRepository,
        _filesRepository = filesRepository,
        _settingsRepository = settingsRepository,
        super(const ConfigurationTabInitial()) {
    on<ConfigurationTabLoadedSuccess>(_onConfigurationTabLoadedSuccess);
    on<ConfigurationTabSwitchSaveProfile>(_onConfigurationTabSwitchSaveProfile);
    on<ConfigurationTabUpdateFullSave>(_onConfigurationTabUpdateFullSave);

    // TODO takeUntil + destroy$ ?!?!?!?!
    CombineLatestStream.list([
      _saveProfileDatabaseRepository.getByGameIdStream(game.id),
      _settingsRepository.launcherSettings,
    ]).takeUntil(_destroy$).listen((values) {
      final saveProfiles = values[0] as List<SaveProfileModel>;
      final launcherSettings = values[1] as LauncherSettings;
      add(ConfigurationTabLoadedSuccess(
        saveProfiles: saveProfiles,
        launcherSettings: launcherSettings,
      ));
    });
  }

  final GameModel _game;
  final GameEngineModel _gameEngine;
  final GameDatabaseRepository _gameDatabaseRepository;
  final SaveProfileDatabaseRepository _saveProfileDatabaseRepository;
  final FilesRepository _filesRepository;
  final SettingsRepository _settingsRepository;

  final PublishSubject<bool> _destroy$ = PublishSubject<bool>();

  _onConfigurationTabLoadedSuccess(
    ConfigurationTabLoadedSuccess event,
    Emitter<ConfigurationTabState> emit,
  ) {
    emit(ConfigurationTabLoaded(
      saveProfiles: event.saveProfiles,
      launcherSettings: event.launcherSettings,
    ));
  }

  _onConfigurationTabSwitchSaveProfile(
    ConfigurationTabSwitchSaveProfile event,
    Emitter<ConfigurationTabState> emit,
  ) async {
    if (state is ConfigurationTabLoaded) {
      final castState = state as ConfigurationTabLoaded;

      if (_game.savesPath == null) {
        // TODO error logging
        // TODO _logger.e("No savespath found for game ${game.name}!");
        return;
      }
      // Abort if game not installed
      if (!_game.installed) {
        // TODO _logger.e("Unable to activate save profile - Game not installed!");
        return;
      }

      SaveProfileModel currentActive = getActiveProfile();

      bool success = await _deactivateSaveProfile(
        state: castState,
        saveProfile: currentActive,
      );
      if (!success) {
        /*_logger.e(
          "Failed to deactivate save profile ${currentActive.name} for game ${game.name}",);*/
        // TODO error handling
      }
      success = await _activateSaveProfile(
        state: castState,
        saveProfile: event.newSaveProfile,
      );
      if (!success) {
        /*_logger.e(
          "Failed to activate save profile ${newActiveProfile.name} for game ${game.name}",);*/
        // TODO error handling (perhaps try to reactivate current one)
      }

      // Update state
      // TODO refetch saveProfilesByGameId
    }
  }

  SaveProfileModel getActiveProfile() {
    if (state is ConfigurationTabLoaded) {
      return (state as ConfigurationTabLoaded)
          .saveProfiles
          .firstWhere((profile) => profile.active);
    }
    throw UnsupportedError(
      "Unable to get active profile if profiles not loaded.",
    );
  }

  Future<bool> _deactivateSaveProfile({
    required ConfigurationTabLoaded state,
    required SaveProfileModel saveProfile,
  }) async {
    try {
      Directory gameSaveDirectory =
          _filesRepository.getDirectory(_game.savesPath!);

      // Check if absoluteGameSavePath exists -> copy, otherwise warning
      //  (just warning after all could be that game has never been started -> save dir not yet created)
      if (gameSaveDirectory.existsSync()) {
        // Get all save files
        // TODO IF THERE ARE NO SAVES YET, THE FOLDER MIGHT NOT EXIST
        List<FileSystemEntity> saveFiles = await getAllFilesWithExtension(
          path: p.join(gameSaveDirectory.absolute.path),
          extensions: _gameEngine.saveFileExtensions,
        );

        // Copy save files from saves directory to profile directory
        final String profileDirectoryPath = _filesRepository
            .getDirectory(p.join(
              _game.metadataPath,
              FilesRepository.saveProfileDirectoryName,
              saveProfile.profileDirectoryName,
            ))
            .path;
        List<Future<FileSystemEntity>> copyFutures = [];
        for (var file in saveFiles) {
          String filename = p.basename(file.path);
          copyFutures.add(file.copy(
            p.join(
              profileDirectoryPath,
              filename,
            ),
            recursive: true,
          ));
        }
        await Future.wait(copyFutures);
        // TODO clear current saves folder!!!!!!!!
        // TODO perhaps move the clear into activate -> if deactivate succeeds, but activate fails at least sth is active
        //  -> BUT IF THEN ACTIVATE FAILS -> SAME ISSUE
        // Delete current save files
        List<Future<FileSystemEntity>> deleteFutures = [];
        for (var file in saveFiles) {
          deleteFutures.add(file.delete(recursive: true));
        }
        await Future.wait(deleteFutures);
      } else {
        /*_logger.w(
            "$absoluteGameSavePath does not exist - deactivation did not copy anything!");*/
        // TODO
      }

      // Mark as inactive
      // TODO unsure if UI reflects update
      saveProfile = saveProfile.copyWith(active: false);
      await _saveProfileDatabaseRepository.update(saveProfile);

      return true;
    } catch (e) {
      // TODO _logger.e(e.toString());
      return false;
    }
  }

  Future<bool> _activateSaveProfile({
    required ConfigurationTabLoaded state,
    required SaveProfileModel saveProfile,
  }) async {
    try {
      // Get all save files in profile folder
      // TODO where to save profile folder?!?!, currently inside saves folder
      List<FileSystemEntity> saveFiles = [];
      try {
        saveFiles = await getAllFilesWithExtension(
          path: _filesRepository
              .getDirectory(p.join(
                _game.metadataPath,
                FilesRepository.saveProfileDirectoryName,
                saveProfile.profileDirectoryName,
              ))
              .path,
          extensions: _gameEngine.saveFileExtensions,
        );
      } catch (e) {
        /*ErrorUtils.displayError(
            "Failed to activate save profile - Save files not found!");*/
        // TODO
        return false;
      }

      // Copy save files from profile folder to saves folder
      Directory gameSaveDirectory =
          _filesRepository.getDirectory(_game.savesPath!);
      List<Future<FileSystemEntity>> copyFutures = [];
      for (var file in saveFiles) {
        String filename = p.basename(file.path);
        copyFutures.add(file.copy(
          p.join(
            gameSaveDirectory.path,
            filename,
          ),
          recursive: true,
        ));
      }
      await Future.wait(copyFutures);

      // Mark as active
      // TODO unsure if UI reflects update
      saveProfile = saveProfile.copyWith(active: true);
      await _saveProfileDatabaseRepository.update(saveProfile);

      return true;
    } catch (e) {
      // TODO _logger.e(e.toString());
      return false;
    }
  }

  _onConfigurationTabUpdateFullSave(
    ConfigurationTabUpdateFullSave event,
    Emitter<ConfigurationTabState> emit,
  ) async {
    if (state is ConfigurationTabLoaded) {
      final updatedGame = _game.copyWith(fullSaveAvailable: event.fullSave);
      await _gameDatabaseRepository.update(updatedGame);
    }
  }

  @override
  Future<void> close() {
    _destroy$.add(true);
    return super.close();
  }
}
