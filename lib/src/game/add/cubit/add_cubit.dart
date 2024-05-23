import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:database_repository/database_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:files_repository/files_repository.dart';
import 'package:game_launcher/src/game/add/details_form/models/index.dart';
import 'package:game_launcher/src/shared/utils/file_utils.dart';
import 'package:path/path.dart' as p;
import 'package:shared_kernel/shared_kernel.dart';

part 'add_state.dart';

class AddCubit extends Cubit<AddState> {
  AddCubit({
    required String archiveFilePath,
    required FilesRepository filesRepository,
    required ArchivesRepository archivesRepository,
    required GameDatabaseRepository gameDatabaseRepository,
    required GameEngineRepository gameEngineRepository,
  })  : _archiveFilePath = archiveFilePath,
        _filesRepository = filesRepository,
        _archivesRepository = archivesRepository,
        _gameDatabaseRepository = gameDatabaseRepository,
        _gameEngineRepository = gameEngineRepository,
        super(AddInitial()) {
    _analyzeArchive();
  }

  int get stepperLength => 3;
  final String _archiveFilePath;
  final FilesRepository _filesRepository;
  final ArchivesRepository _archivesRepository;
  final GameDatabaseRepository _gameDatabaseRepository;
  final GameEngineRepository _gameEngineRepository;

  _analyzeArchive() async {
    Directory analyzingTmpDir =
        _filesRepository.getDirectory(_filesRepository.gameAnalyzingPath);
    if (await analyzingTmpDir.exists()) {
      try {
        await analyzingTmpDir.delete(recursive: true);
      } catch (e) {
        emit(AddAnalysisFailed(error: "Failed to delete .analyzing folder!"));
        return;
      }
    }
    await analyzingTmpDir.create();
    if (isClosed) return;
    // Extract archive to tmp
    var archivingProcess = await _archivesRepository.extractArchive(
      archiveFile: File(_archiveFilePath),
      destination: analyzingTmpDir,
    );
    emit(AddAnalysing(archivingPid: archivingProcess.pid));
    try {
      final absoluteGamePath = await archivingProcess.archivingFuture;
      if (isClosed) return;
      // extract data from archive (game exe, saves, engine, ...)
      final analysisResult = await _extractDataFromLocation(absoluteGamePath);
      if (isClosed) return;
      // Failed to detect engine -> popup for user that asks whether he wants to select root of game (in case wrapperDirs caused this)
      // TODO -> unable to use GameModel due to it not allowing partial -> create new model
      // TODO update form data in gameDatabaseRepository
      print("Update");
      _gameDatabaseRepository.updateAnalysisResult(
        gamePath: analysisResult.absoluteGamePath,
        name: analysisResult.name,
        gameEngineEnum: analysisResult.gameEngineEnum,
        version: analysisResult.version,
        absoluteExePath: analysisResult.engineBasedData?.absoluteExePath,
        absoluteSavesPath: analysisResult.engineBasedData?.absoluteSavesPath,
      );
      if (analysisResult.gameEngineEnum == null) {
        emit(AddAnalysisUnknownEngine());
      } else if (analysisResult.gameEngineEnum == GameEngineEnum.unity) {
        emit(AddAnalysisUnityEngine());
      } else {
        startForms();
      }
    } on ExecutionException catch (e) {
      print("ExecutionException");
      if (isClosed) return;
      emit(AddAnalysisFailed(error: e.message));
    } catch (e) {
      print("Exception");
      if (isClosed) return;
      emit(AddAnalysisFailed(error: e.toString()));
    }
  }

  Future<AnalysisResult> _extractDataFromLocation(
    String absoluteGamePath,
  ) async {
    // Remove wrapper dirs
    // TODO add to AnalysisResult -> It should always be inside the /tmp/.analysing directory -> can be made localized to _filesRepository
    absoluteGamePath = (await removeWrapperDirectories(
      dir: Directory(absoluteGamePath),
      archiveExtensions: _archivesRepository.supportedArchiveExtensions,
    ))
        .path;
    // Try to select game engine
    final engineEmum =
        await _gameEngineRepository.getGameEngineFromGameLocation(
      absoluteGamePath: absoluteGamePath,
    );

    // Use folder name as game name, IF GAME NAME EMPTY
    /*Uri asUri = Uri.file(absoluteGamePath);
    String name = asUri.pathSegments.last;*/
    String name = p.basename(absoluteGamePath);

    // Try to extract version from name
    final version = Version.regexMatcher.firstMatch(name)?.group(0);

    // Remove version from name
    if (version != null) {
      name = name.replaceFirst(version, "").trim();
    }

    return AnalysisResult(
      absoluteGamePath: absoluteGamePath,
      name: name,
      version: version,
      gameEngineEnum: engineEmum,
      engineBasedData: engineEmum != null
          ? await _extractDataFromGameEngine(absoluteGamePath, engineEmum)
          : null,
    );
  }

  Future<EngineBasedData> _extractDataFromGameEngine(
    String gamePath,
    GameEngineEnum engineEnum,
  ) async {
    final engine = _gameEngineRepository.getGameEngine(engineEnum);
    // Try to get exe
    final absoluteExePath = await engine.getGameExecutableAbsolutePath(
      absoluteGamePath: gamePath,
    );
    // Try to select saves path
    final absoluteSavesPath = await engine
        .getDefaultSavesPath(absoluteGamePath: gamePath)
        .catchError((error) {
      // TODO ErrorUtils.displayError(error);
      return null;
    });

    return EngineBasedData(
      absoluteExePath: absoluteExePath,
      absoluteSavesPath: absoluteSavesPath,
    );
  }

  manualGameLocationSelected(String? manualGameLocation) async {
    if (manualGameLocation != null &&
        manualGameLocation != _gameDatabaseRepository.creationGame.path) {
      final absoluteAnalyzingPath = _filesRepository
          .getDirectory(_filesRepository.gameAnalyzingPath)
          .path;
      if (!p.isWithin(absoluteAnalyzingPath, manualGameLocation)) {
        // TODO
        emit(const AddAnalysisFailed(
          error: "Selected path outside game analyzing directory.",
        ));
        return;
      }
      final analysisResult = await _extractDataFromLocation(manualGameLocation);
      if (isClosed) return;
      _gameDatabaseRepository.updateAnalysisResult(
        gamePath: analysisResult.absoluteGamePath,
        name: analysisResult.name,
        gameEngineEnum: analysisResult.gameEngineEnum,
        version: analysisResult.version,
        absoluteExePath: analysisResult.engineBasedData?.absoluteExePath,
        absoluteSavesPath: analysisResult.engineBasedData?.absoluteSavesPath,
      );
      if (analysisResult.gameEngineEnum == null) {
        // TODO I think I should just set it to custom and enforce manual path selection
        //emit(AddAnalysisFailed(error: "Failed to detect game engine"));
        startForms();
      } else if (analysisResult.gameEngineEnum == GameEngineEnum.unity) {
        emit(AddAnalysisUnityEngine());
      } else {
        startForms();
      }
    } else {
      // TODO I think I should just set it to custom and enforce manual path selection
      //emit(AddForms(activeStepperIndex: 0));
      startForms();
    }
  }

  startForms() {
    if (state is! AddForms) {
      emit(const AddForms(activeStepperIndex: 0));
    }
  }

  void stepContinued() {
    if (state is AddForms) {
      final castState = state as AddForms;
      if (castState.activeStepperIndex < stepperLength - 1) {
        emit(castState.copyWith(
          activeStepperIndex: castState.activeStepperIndex + 1,
        ));
      } else {
        emit(castState.copyWith(
          activeStepperIndex: castState.activeStepperIndex,
        ));
      }
    }
  }

  void stepCancelled() {
    if (state is AddForms) {
      final castState = state as AddForms;
      if (castState.activeStepperIndex > 0) {
        emit(castState.copyWith(
          activeStepperIndex: castState.activeStepperIndex - 1,
        ));
      } else {
        emit(castState.copyWith(
          activeStepperIndex: castState.activeStepperIndex,
        ));
      }
    }
  }

  @override
  Future<void> close() {
    if (state is AddAnalysing) {
      _archivesRepository
          .killArchivingProcess((state as AddAnalysing).archivingPid);
      try {
        _filesRepository
            .getDirectory(_filesRepository.gameAnalyzingPath)
            .deleteSync(recursive: true);
      } catch (e) {
        // TODO ErrorUtils.displayError("Failed to delete tmp files.");
        print(e.toString());
      }
    }
    return super.close();
  }
}

class AnalysisResult {
  final String absoluteGamePath;
  final String name;
  final String? version;
  final GameEngineEnum? gameEngineEnum;
  final EngineBasedData? engineBasedData;

  AnalysisResult({
    required this.absoluteGamePath,
    required this.name,
    required this.version,
    required this.gameEngineEnum,
    required this.engineBasedData,
  });
}

class EngineBasedData {
  final String? absoluteExePath;
  final String? absoluteSavesPath;

  EngineBasedData({
    required this.absoluteExePath,
    required this.absoluteSavesPath,
  });
}
