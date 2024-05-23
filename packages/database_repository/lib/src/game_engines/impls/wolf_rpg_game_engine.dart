import 'dart:io';

import 'package:database_repository/src/game_engines/index.dart';
import 'package:database_repository/src/game_engines/impls/rpgm_game_engine.dart';
import 'package:path/path.dart' as p;

final class WolfRPGGameEngine extends RPGMakerGameEngine {
  WolfRPGGameEngine()
      : super(
          gameEngineEnum: GameEngineEnum.wolfRpg,
          displayName: "Wolf RPG",
          saveFileExtensions: [".sav"],
          ignoredExes: ["Config.exe"],
        );

  @override
  Future<bool> detectGameEngineFromGameFiles(
    List<FileSystemEntity> gameDirContent,
  ) {
    List<String> basenames =
        gameDirContent.map((element) => p.basename(element.path)).toList();
    return Future.value(
        (basenames.contains("Data") || basenames.contains("Data.wolf")) &&
            basenames.contains("GuruguruSMF4.dll"));
  }

  @override
  Future<String?> getDefaultSavesPath({required String absoluteGamePath}) {
    String path = p.join(absoluteGamePath, "Save");
    return Future.value(path);
  }
}
