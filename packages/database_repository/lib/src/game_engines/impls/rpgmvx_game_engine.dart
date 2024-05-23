import 'dart:io';

import 'package:database_repository/src/game_engines/index.dart';
import 'package:database_repository/src/game_engines/impls/rpgm_game_engine.dart';
import 'package:path/path.dart' as p;

class RPGMakerVXGameEngine extends RPGMakerGameEngine {
  RPGMakerVXGameEngine()
      : super(
          gameEngineEnum: GameEngineEnum.rpgmakerVX,
          displayName: "RPG Maker VX",
          saveFileExtensions: [".rvdata"],
        );

  @override
  Future<bool> detectGameEngineFromGameFiles(
    List<FileSystemEntity> gameDirContent,
  ) {
    // TODO: implement detectGameEngineFromGamePath
    List<String> basenames =
        gameDirContent.map((element) => p.basename(element.path)).toList();
    return Future.value(basenames.contains("Data") &&
        basenames.contains("Graphics") &&
        !basenames.contains(
            "System")); // !contains("System") because that would be XP ACE
  }

  @override
  Future<String?> getDefaultSavesPath({required String absoluteGamePath}) {
    String path = absoluteGamePath;
    return Future.value(path);
  }
}
