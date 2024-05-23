import 'dart:io';

import 'package:database_repository/src/game_engines/index.dart';
import 'package:path/path.dart' as p;

class UnrealGameEngine extends GameEngineModel {
  UnrealGameEngine()
      : super(
          gameEngineEnum: GameEngineEnum.unreal,
          displayName: "Unreal Engine",
          saveFileExtensions: [".sav"],
        );

  @override
  Future<bool> detectGameEngineFromGameFiles(
    List<FileSystemEntity> gameDirContent,
  ) {
    // TODO: implement detectGameEngineFromGamePath
    // Contains Engine folder (at least the one time I found a game)
    //throw UnimplementedError();
    return Future.value(false);
  }

  @override
  Future<String?> getDefaultSavesPath({required String absoluteGamePath}) {
    // TODO: implement getDefaultSavesPath
    // Default seems to be %LocalAppData%\GAME_NAME\Saved\SaveGames
    //throw UnimplementedError();
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
}
