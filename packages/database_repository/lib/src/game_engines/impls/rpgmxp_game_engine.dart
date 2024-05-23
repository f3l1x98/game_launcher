import 'dart:io';

import 'package:database_repository/src/game_engines/index.dart';
import 'package:database_repository/src/game_engines/impls/rpgm_game_engine.dart';
import 'package:path/path.dart' as p;

class RPGMakerXPGameEngine extends RPGMakerGameEngine {
  RPGMakerXPGameEngine()
      : super(
          gameEngineEnum: GameEngineEnum.rpgmakerXP,
          displayName: "RPG Maker XP",
          saveFileExtensions: [".rxdata"],
        );

  @override
  Future<bool> detectGameEngineFromGameFiles(
    List<FileSystemEntity> gameDirContent,
  ) {
    // TODO: implement detectGameEngineFromGamePath
    //throw UnimplementedError();
    return Future.value(false);
  }

  @override
  Future<String?> getDefaultSavesPath({required String absoluteGamePath}) {
    // TODO not yet known
    String path = absoluteGamePath;
    return Future.value(path);
  }
}
