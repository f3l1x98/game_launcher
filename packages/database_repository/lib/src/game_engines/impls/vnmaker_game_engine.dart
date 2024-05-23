import 'dart:io';

import 'package:database_repository/src/game_engines/index.dart';
import 'package:path/path.dart' as p;

class VNMakerGameEngine extends GameEngineModel {
  VNMakerGameEngine()
      : super(
          gameEngineEnum: GameEngineEnum.vnmaker,
          displayName: "VN Maker",
          saveFileExtensions: [".vndata"],
        );

  @override
  Future<bool> detectGameEngineFromGameFiles(
    List<FileSystemEntity> gameDirContent,
  ) {
    List<String> basenames =
        gameDirContent.map((element) => p.basename(element.path)).toList();
    return Future.value(basenames.contains("icudtl.dat") &&
        basenames.contains("data") &&
        basenames.contains("locales") &&
        !basenames.contains("www"));
  }

  @override
  Future<String?> getDefaultSavesPath({required String absoluteGamePath}) {
    String path = absoluteGamePath;
    return Future.value(path);
  }

  @override
  Future<String?> getGameExecutableAbsolutePath({
    String? absoluteGamePath,
  }) async {
    if (absoluteGamePath == null || absoluteGamePath.isEmpty) {
      return null;
    }
    List<File> exes = await getAllExes(absoluteGamePath);

    if (exes.length == 1) {
      return exes[0].path;
    } else if (exes.length > 1) {
      int gameExeIndex = exes.indexWhere(
          (exe) => p.basename(exe.path).toLowerCase() == "game_en.exe");
      if (gameExeIndex >= 0) {
        return exes[gameExeIndex].path;
      }
      gameExeIndex = exes.indexWhere(
          (exe) => p.basename(exe.path).toLowerCase() == "game.exe");
      if (gameExeIndex >= 0) {
        return exes[gameExeIndex].path;
      }
    }

    return null;
  }
}
