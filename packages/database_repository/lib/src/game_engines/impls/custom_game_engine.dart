import 'dart:io';

import 'package:database_repository/src/game_engines/index.dart';
import 'package:path/path.dart' as p;

class CustomGameEngine extends GameEngineModel {
  CustomGameEngine()
      : super(
          gameEngineEnum: GameEngineEnum.custom,
          displayName: "Custom",
          saveFileExtensions: [],
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
    // TODO: implement getDefaultSavesPath
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
