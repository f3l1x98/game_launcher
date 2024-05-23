import 'dart:io';

import 'package:database_repository/src/game_engines/game_engine_enum.dart';
import 'package:database_repository/src/game_engines/game_engine_model.dart';
import 'package:database_repository/src/game_engines/impls/index.dart';

class GameEngineRepository {
  final Map<GameEngineEnum, GameEngineModel> _gameEngines = {
    GameEngineEnum.renpy: RenpyGameEngine(),
    GameEngineEnum.unity: UnityGameEngine(),
    GameEngineEnum.unreal: UnrealGameEngine(),
    GameEngineEnum.rpgmakerXP: RPGMakerXPGameEngine(),
    GameEngineEnum.rpgmakerVX: RPGMakerVXGameEngine(),
    GameEngineEnum.rpgmakerMV: RPGMakerMVGameEngine(),
    GameEngineEnum.rpgmakerMZ: RPGMakerMZGameEngine(),
    GameEngineEnum.rpgmakerVXAce: RPGMakerVXAceGameEngine(),
    GameEngineEnum.vnmaker: VNMakerGameEngine(),
    GameEngineEnum.custom: CustomGameEngine(),
    GameEngineEnum.wolfRpg: WolfRPGGameEngine(),
  };

  GameEngineModel getGameEngine(GameEngineEnum gameEngineEnum) {
    return _gameEngines[gameEngineEnum]!;
  }

  List<GameEngineModel> getAllGameEngines() {
    return _gameEngines.values.toList();
  }

  Future<GameEngineEnum?> getGameEngineFromGameLocation({
    required String absoluteGamePath,
  }) async {
    List<FileSystemEntity> gameFiles =
        await Directory(absoluteGamePath).list().toList();
    List<GameEngineModel> gameEngineHandlers = getAllGameEngines();
    for (var gameEngineHandler in gameEngineHandlers) {
      // TODO how to handle multiple true detections (currently first match returned)
      bool gameEngineDetected =
          await gameEngineHandler.detectGameEngineFromGameFiles(gameFiles);
      if (gameEngineDetected) {
        return gameEngineHandler.gameEngineEnum;
      }
    }
    return null;
  }
}
