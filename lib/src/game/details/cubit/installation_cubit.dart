import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:database_repository/database_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:files_repository/files_repository.dart';
import 'package:game_launcher/src/extensions/archive_extensions.dart';
import 'package:game_launcher/src/extensions/directory_extensions.dart';
import 'package:game_launcher/src/shared/utils/file_utils.dart';
import 'package:progress_repository/progress_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:path/path.dart' as p;

part 'installation_state.dart';

class InstallationCubit extends Cubit<InstallationState> {
  InstallationCubit({
    required GameModel game,
    required GameDatabaseRepository gameDatabaseRepository,
    required SaveProfileDatabaseRepository saveProfileDatabaseRepository,
    required ProgressRepository progressRepository,
    required FilesRepository filesRepository,
    required ArchivesRepository archivesRepository,
  })  : _archivesRepository = archivesRepository,
        _filesRepository = filesRepository,
        _progressRepository = progressRepository,
        _saveProfileDatabaseRepository = saveProfileDatabaseRepository,
        _gameDatabaseRepository = gameDatabaseRepository,
        _game = game,
        super(InstallationIdle()) {
    _progressRepository.progresses.takeUntil(_destroy$).listen((event) {
      if (state is InstallationRunning) {
        final progress = event.firstWhereOrNull((progress) =>
            progress.id == (state as InstallationRunning).progressId);
        if (progress == null) {
          emit(InstallationIdle());
        }
      }
    });
  }

  // TODO unsure if part of state or not
  final GameModel _game;
  final GameDatabaseRepository _gameDatabaseRepository;
  final SaveProfileDatabaseRepository _saveProfileDatabaseRepository;
  final ProgressRepository _progressRepository;
  final FilesRepository _filesRepository;
  final ArchivesRepository _archivesRepository;

  final PublishSubject<bool> _destroy$ = PublishSubject<bool>();

  Future<void> install() async {
    assert(state is! InstallationRunning);
    Progress progress = Progress(
      name: "Install ${_game.name}",
      max: 3,
      description: "Checking data...",
    );
    _progressRepository.upsertProgress(progress);
    emit(InstallationRunning(progressId: progress.id));
    Directory? gameTmpDir;
    try {
      // TODO SPLIT INTO SEPARATE METHODS
      Progress progress = Progress(
        name: "Install ${_game.name}",
        max: 3,
        description: "Checking data...",
      );
      _progressRepository.upsertProgress(progress);
      emit(InstallationRunning(progressId: progress.id));

      // TODO path vs gameDirectoryName
      // -> games are located inside _filesRepository.rootPath -> game.path == "/<SANITIZED_GAME_NAME>"
      Directory gameDirectory = _filesRepository.getDirectory(_game.path);

      if (await alreadyInstalled(gameDirectory)) {
        return;
      }

      // Unzip game
      progress = Progress.advanceBase(
        base: progress,
        newDescription: "Extracting archive...",
      );
      _progressRepository.upsertProgress(progress);
      (gameTmpDir, progress) = await _unzipToTmp(progress);

      progress = await _copyGameFromTmp(
        progress: progress,
        gameTmpDir: gameTmpDir,
        gameDirectory: gameDirectory,
      );

      // Update game (installed, paths, ...)
      progress = Progress.advanceBase(
        base: progress,
        newDescription: "Update game data...",
      );
      _progressRepository.upsertProgress(progress);

      await _gameDatabaseRepository.update(_game.copyWith(installed: true));

      progress = Progress.advanceBase(
        base: progress,
        newDescription: "Finished",
      );
    } catch (e) {
      // TODO _logger.e(e.toString());
      // Abort transaction
      // TODO
      emit(InstallationFailed(error: e.toString()));
    } finally {
      // Cleanup tmp dir
      if (gameTmpDir != null) {
        await gameTmpDir.delete(recursive: true);
      }
    }
  }

  alreadyInstalled(Directory gameDirectory) async {
    bool gameDirExists = await gameDirectory.exists();
    if (_game.installed && gameDirExists) {
      return true;
    } else if (!_game.installed && gameDirExists) {
      // TODO
      throw Exception(); /*GameInstallException(
          message: "Game not installed but files found!",
          game: game,
        );*/
    }
    return false;
  }

  Future<(Directory, Progress)> _unzipToTmp(Progress progress) async {
    // create gamefolder in tmp in order to extract into a controllable directory (zip might not contain a wrapping folder)
    String gameDirectoryName = _game.gameDirectoryName;
    final gameTmpDir = await _filesRepository
        .getDirectory(p.join(
          _filesRepository.gamesTempPath,
          gameDirectoryName,
        ))
        .create(); // TODO exception handling

    final archivingProcess = await _archivesRepository.extractArchive(
      archiveFile: _filesRepository.getFile(p.join(
        _filesRepository.gamesUninstalledPath,
        _game.archiveFileName,
      )),
      destination: gameTmpDir,
      onProgressChanged: (archivingProgress) {
        progress = progress.copyWith(
          childProgress: archivingProgress.toProgress(),
        );
        _progressRepository.upsertProgress(progress);
      },
    );
    await archivingProcess.archivingFuture;
    // Reset internal progress
    progress = progress.copyWith(
      childProgress: null,
    );
    _progressRepository.upsertProgress(progress);

    return (gameTmpDir, progress);
  }

  Future<Progress> _copyGameFromTmp({
    required Progress progress,
    required Directory gameTmpDir,
    required Directory gameDirectory,
  }) async {
    // Check if gameTmpDir contains wrapper dir and skip them for copy
    Directory gameTmpDirToCopy = await removeWrapperDirectories(
      dir: gameTmpDir,
      archiveExtensions: _archivesRepository.supportedArchiveExtensions,
    );

    // move to gamesBasePath
    // TODO FOR SOME REASON THIS DOES NOT COPY EVERYTING (missing js/libs/*)
    await gameTmpDirToCopy.copyTo(
      gameDirectory,
      recursive: true,
      onProgressUpdate: (copyProgress) {
        progress = progress.copyWith(
          childProgress: copyProgress,
        );
        _progressRepository.upsertProgress(progress);
      },
    );
    // Reset internal progress
    progress = progress.copyWith(
      childProgress: null,
    );
    _progressRepository.upsertProgress(progress);
    return progress;
  }

  Future<void> uninstall() async {
    assert(state is! InstallationRunning);

    try {
      // TODO SPLIT INTO SEPARATE METHODS
      Progress progress = Progress(
        name: "Uninstall ${_game.name}",
        max: 4,
        description: "Checking data...",
      );
      _progressRepository.upsertProgress(progress);
      // Check if installed (and found on disk)
      final gameDirectory = _filesRepository.getDirectory(_game.path);
      if (!_game.installed && !(await gameDirectory.exists())) {
        return;
      }
      // Zip game
      progress = Progress.advanceBase(
        base: progress,
        newDescription: "Archiving...",
      );
      _progressRepository.upsertProgress(progress);
      String archiveName = _game.archiveFileName;
      // create archive
      final archivingProcess = await _archivesRepository.archiveDirectory(
        directory: gameDirectory,
        // TODO gamesUninstalledPath IS ALREADY ABSOLUTE!!!!!!
        archiveDestination: _filesRepository
            .getDirectory(_filesRepository.gamesUninstalledPath),
        archiveFileName: archiveName,
        includeBaseDirectory: true,
        onProgressChanged: (archivingProgress) {
          progress = progress.copyWith(
            childProgress: archivingProgress.toProgress(),
          );
          _progressRepository.upsertProgress(progress);
        },
      );
      await archivingProcess.archivingFuture;
      progress = progress.copyWith(
        childProgress: null,
      );
      progress = Progress.advanceBase(
        base: progress,
        newDescription: "Updating database...",
      );
      _progressRepository.upsertProgress(progress);
      // Update game (installed, ...)
      await _gameDatabaseRepository.update(_game.copyWith(installed: false));

      progress = Progress.advanceBase(
        base: progress,
        newDescription: "Deleting game files...",
      );
      _progressRepository.upsertProgress(progress);
      // Delete game folder
      await gameDirectory.delete(recursive: true);

      progress = Progress.advanceBase(
        base: progress,
        newDescription: "Finished",
      );
      _progressRepository.upsertProgress(progress);
    } catch (e) {
      // TODO IN CASE OF MULTIPLE RUNNING PROCESSES: This widget has been unmounted, so the State no longer has a context (and should be considered defunct).
      // TODO _logger.e(e.toString());
      // Abort transaction
      // TODO
    } finally {
      // Cleanup tmp dir
      // TODO
    }
  }

  Future<void> update({
    required String newVersion,
    required File newVersionArchiveFile,
    bool copyCurrentSave = false,
  }) async {
    assert(state is! InstallationRunning);

    if (!_game.installed) {
      return;
    }

    if (!await newVersionArchiveFile.exists()) {
      // TODO ErrorUtils.displayError("Archive $newVersionArchive not found!");
      emit(InstallationFailed(
          error: "Archive ${newVersionArchiveFile.path} not found!"));
      return;
    }
    // TODO SPLIT INTO SEPARATE METHODS
    Directory? gameTmpDirectory;
    try {
      Progress progress = Progress(
        name: "Update ${_game.name}",
        max: 5,
        description: "Checking data...",
      );
      _progressRepository.upsertProgress(progress);

      // -------------------- Extract update archive --------------------

      // Extract new version into tmp
      progress = Progress.advanceBase(
        base: progress,
        newDescription: "Extracting new version...",
      );
      _progressRepository.upsertProgress(progress);
      // TODO
      final String gameDirectoryName = _game.gameDirectoryName;
      gameTmpDirectory = _filesRepository.getDirectory(
          p.join(_filesRepository.gamesTempPath, gameDirectoryName));
      final archivingProcess = await _archivesRepository.extractArchive(
        archiveFile: newVersionArchiveFile,
        destination: gameTmpDirectory,
        onProgressChanged: (extractProgress) {
          progress = progress.copyWith(
            childProgress: extractProgress.toProgress(),
          );
          _progressRepository.upsertProgress(progress);
        },
      );
      await archivingProcess.archivingFuture;
      progress = progress.copyWith(
        childProgress: null,
      );
      _progressRepository.upsertProgress(progress);
      // After extraction remove potential wrapper dirs
      gameTmpDirectory = await removeWrapperDirectories(
        dir: gameTmpDirectory,
        archiveExtensions: _archivesRepository.supportedArchiveExtensions,
      );

      progress = Progress.advanceBase(
        base: progress,
        newDescription: "Creating save profile backup...",
      );
      _progressRepository.upsertProgress(progress);

      // TODO AT LEAST IN CASE OF RENPY THE SAVE DIR MIGHT HAVE CHANGED -> RE-EXTRACT SAVE_LOCATION!!

      // -------------------- Save profile management --------------------

      /*game = await _updateSaveProfiles(
        copyCurrentSave: copyCurrentSave,
        newVersion: newVersion,
        progress: progress,
      );*/

      // -------------------- Copy from tmp to base --------------------

      // Delete old game version files
      final gameDirectory = _filesRepository.getDirectory(_game.path);
      await gameDirectory.delete(recursive: true);
      // Move update folder to gameBasePath -> game.path remains the same
      await gameTmpDirectory.copyTo(
        gameDirectory,
        recursive: true,
        onProgressUpdate: (copyProgress) {
          progress = progress.copyWith(
            childProgress: copyProgress,
          );
          _progressRepository.upsertProgress(progress);
        },
      );
      progress = progress.copyWith(
        childProgress: null,
      );
      _progressRepository.upsertProgress(progress);

      // -------------------- Handle DB updates --------------------

      // Update db
      progress = Progress.advanceBase(
        base: progress,
        newDescription: "Updating game...",
      );
      _progressRepository.upsertProgress(progress);
      await _gameDatabaseRepository.update(_game.copyWith(
        version: newVersion,
        archiveFileName: p.basename(newVersionArchiveFile.path),
      ));

      progress = Progress.advanceBase(
        base: progress,
        newDescription: "Finished",
      );
      _progressRepository.upsertProgress(progress);
    } catch (e) {
      // TODO _logger.e(e.toString());
      // Abort transaction
      // TODO
    } finally {
      // Cleanup tmp dir
      // TODO
      if (gameTmpDirectory != null) {
        await gameTmpDirectory.delete(recursive: true);
      }
    }
  }

  @override
  Future<void> close() {
    _destroy$.add(true);
    return super.close();
  }

  // TODO THIS REQUIRES A LOT OF ADDITIONAL LOGIC AND VARIABLES (most of them also present in the configuration_tab)
  Future<GameModel> _updateSaveProfiles({
    required bool copyCurrentSave,
    required String newVersion,
    required Progress progress,
  }) async {
    throw UnimplementedError();
    // deactivate current active save profile
    /*GameSaveProfileModel activeProfile = game.saveProfiles.firstWhere(
      (profile) => profile.active,
    );
    // TODO HANDLE IF NOT INSTALLED -> CANNOT BE DEACTIVATED DUE TO DIRECTORY MISSING
    bool success = await _saveProfileDatabaseRepository!.deactivateSaveProfile(
      game: game,
      gameSaveProfile: activeProfile,
    );
    if (!success) {
      // TODO
      throw GameUpdateException(
        message:
            "Failed to deactivate active save profile ${activeProfile.name} for game ${game.name}",
        game: game,
      );
    }

    // TODO backup default save in new save because preexisting save in update will be new default save
    // Create backup profile for current default profile
    String defaultBackupProfileName = "Default_${game.version}";
    game = await createSaveProfile(
      game: game,
      name: defaultBackupProfileName,
      prefillWithCurrent: false,
    );
    GameSaveProfileModel defaultProfile = game.saveProfiles.firstWhere(
      (profile) => profile.name == "Default",
    );
    GameSaveProfileModel defaultBackupProfile = game.saveProfiles.firstWhere(
      (profile) => profile.name == defaultBackupProfileName,
    );
    Directory defaultProfileAbsoluteDirectory = saveProfileDatabaseService!
        .getAbsoluteProfileDirectory(absoluteGameMetadataPath, defaultProfile);

    // copy default save files into new backup
    await defaultProfileAbsoluteDirectory.copyTo(saveProfileDatabaseService!
        .getAbsoluteProfileDirectory(
            absoluteGameMetadataPath, defaultBackupProfile));
    // If copyCurrentSave = false -> clear, otherwise copy activeProfile
    if (!copyCurrentSave) {
      //await clearDirectory(defaultProfileAbsoluteDirectory);
      await defaultProfileAbsoluteDirectory.clear();
    } else {
      await saveProfileDatabaseService!
          .getAbsoluteProfileDirectory(absoluteGameMetadataPath, activeProfile)
          .copyTo(defaultProfileAbsoluteDirectory);
    }

    // Activate default save
    progress.advanceProgress("Activating default save profile...");
    success = await saveProfileDatabaseService!.activateSaveProfile(
      game: game,
      gameSaveProfile: defaultProfile,
    );
    if (!success) {
      throw GameUpdateException(
        message:
            "Failed to activate default save profile ${defaultProfile.name} for game ${game.name}",
        game: game,
      );
    }

    // Update default save gameVersion to new version
    defaultProfile.gameVersion = newVersion;
    await saveProfileDatabaseService!.updateData(defaultProfile);

    return game;*/
  }
}
