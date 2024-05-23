import 'dart:io';

import 'package:database_repository/src/game_engines/index.dart';
import 'package:database_repository/src/game_engines/impls/rpgm_game_engine.dart';
import 'package:database_repository/src/game_engines/utils/engine_utils.dart';
import 'package:path/path.dart' as p;

class RPGMakerMZGameEngine extends RPGMakerGameEngine {
  RPGMakerMZGameEngine()
      : super(
          gameEngineEnum: GameEngineEnum.rpgmakerMZ,
          displayName: "RPG Maker MZ",
          saveFileExtensions: [".rmmzsave"],
          ignoredExes: ["notification_helper.exe"],
        );

  @override
  Future<bool> detectGameEngineFromGameFiles(
    List<FileSystemEntity> gameDirContent,
  ) {
    List<String> basenames =
        gameDirContent.map((element) => p.basename(element.path)).toList();
    return Future.value(basenames.contains("icudtl.dat") &&
        basenames.contains("notification_helper.exe"));
  }

  @override
  Future<String?> getDefaultSavesPath({required String absoluteGamePath}) {
    String path = p.join(absoluteGamePath, "save");
    return Future.value(path);
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
      String? gameExe = containsExe(exes, "game_en.exe");
      if (gameExe != null) {
        return gameExe;
      }
      gameExe = containsExe(exes, "game.exe");
      if (gameExe != null) {
        return gameExe;
      }
      gameExe = containsExe(exes, "nw.exe");
      if (gameExe != null) {
        return gameExe;
      }
    }

    return null;
  }
}
