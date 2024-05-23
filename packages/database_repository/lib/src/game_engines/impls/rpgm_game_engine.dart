import 'dart:io';

import 'package:database_repository/src/game_engines/utils/engine_utils.dart';
import 'package:database_repository/src/game_engines/index.dart';

abstract class RPGMakerGameEngine extends GameEngineModel {
  RPGMakerGameEngine({
    required super.gameEngineEnum,
    required super.displayName,
    required super.saveFileExtensions,
    super.ignoredExes,
  });

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
    }

    return null;
  }
}
