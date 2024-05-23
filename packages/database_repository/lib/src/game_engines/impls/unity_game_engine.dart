import 'dart:io';

import 'package:database_repository/src/game_engines/index.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class UnityGameEngine extends GameEngineModel {
  UnityGameEngine()
      : super(
          gameEngineEnum: GameEngineEnum.unity,
          displayName: "Unity",
          saveFileExtensions: [".dat", ".save"],
          ignoredExes: [
            "UnityCrashHandler64.exe",
            "UnityCrashHandler32.exe",
          ],
        );

  @override
  Future<bool> detectGameEngineFromGameFiles(
    List<FileSystemEntity> gameDirContent,
  ) {
    return Future.value(gameDirContent
        .any((element) => p.basename(element.path) == "UnityPlayer.dll"));
  }

  @override
  Future<String?> getDefaultSavesPath({required String absoluteGamePath}) {
    // TODO: implement getDefaultSavesPath
    // Potential save locations:
    // :gamePath\SaveData
    // :appData\COMPANY\GAME
    // SOMETIMES IN REGISTRY
    /*String path =
        p.join(PathTemplateService.GAME_PATH_TEMPLATE_KEY, "SaveData");
    if (gamePath == null) {
      throw ArgumentError(
          "Retrieving Unity savepath requires file check and thus the gamePath!");
    }
    String gamesBasePath =
        SettingsProvider.get().getString(StringSettingsKey.gamesBasePath);
    path = PathTemplateService.get().resolvePath(path, {
      PathTemplateService.GAMES_BASE_PATH_TEMPLATE_KEY: gamesBasePath,
      PathTemplateService.GAME_PATH_TEMPLATE_KEY: gamePath,
    });
    return Future.value(path);*/
    return Future.value(null);
  }

  @override
  Future<String?> getGameExecutableAbsolutePath(
      {String? absoluteGamePath}) async {
    if (absoluteGamePath == null || absoluteGamePath.isEmpty) {
      return null;
    }
    List<File> exes = await getAllExes(absoluteGamePath);

    if (exes.length == 1) {
      return exes[0].path;
    } else if (exes.length > 1) {
      // TODO
      /*_logger.w(
        "Unable to determine game exe from list ${exes.map((e) => e.path).join(', ')}",
      );*/
      return null;
    }

    return null;
  }

  Future<Directory> extractAppDataDirectory(String gamePath) async {
    // Get _Data directory
    final gameDataDirectory = await Directory(gamePath).list().firstWhere(
        (element) =>
            element is Directory &&
            p.basename(element.path).endsWith("_Data")) as Directory;

    // Readout app.info in order to get CompanyName and GameName
    final appInfoFile = File(p.join(gameDataDirectory.path, "app.info"));
    if (!appInfoFile.existsSync()) {
      // This should not happen
      throw FileSystemException(
          "app.info file of Unity game not found!", appInfoFile.path);
    }
    final appInfoLines = await appInfoFile.readAsLines();
    if (appInfoLines.length < 2) {
      // TODO _logger.d(appInfoLines.toString());
      throw Exception("app.info contains less than the expected 2 lines!");
    }
    // %AppData%\..\LocalLow\<CompanyName>\<GameName>
    final appData = await getTemporaryDirectory() // TODO path_provider
        .then((tmpDir) => tmpDir.parent.parent.path);
    return Directory(
        p.join(appData, "LocalLow", appInfoLines[0], appInfoLines[1]));
  }
}
