import 'dart:io';

import 'package:database_repository/src/game_engines/index.dart';
import 'package:database_repository/src/game_engines/impls/rpgm_game_engine.dart';
import 'package:path/path.dart' as p;

class RPGMakerVXAceGameEngine extends RPGMakerGameEngine {
  RPGMakerVXAceGameEngine()
      : super(
          gameEngineEnum: GameEngineEnum.rpgmakerVXAce,
          displayName: "RPG Maker VX Ace",
          saveFileExtensions: [
            ".rvdata2",
            ".rvdata"
          ], // .rvdata is for config.rvdata
        );

  @override
  Future<bool> detectGameEngineFromGameFiles(
    List<FileSystemEntity> gameDirContent,
  ) {
    return Future.value(
        gameDirContent.any((element) => p.basename(element.path) == "System"));
  }

  @override
  Future<String?> getDefaultSavesPath({required String absoluteGamePath}) {
    throw Exception(
        "Currently unsupported due to missing access to absoluteGamePath");
    /*String path = gamePath;

    // Check if game folder contains 'savedata' folder -> use this one instead
    if (Directory(p.join(absoluteGamePath, 'savedata')).existsSync()) {
      path = p.join(gamePath, 'savedata');
    }

    return Future.value(path);*/
  }
}
