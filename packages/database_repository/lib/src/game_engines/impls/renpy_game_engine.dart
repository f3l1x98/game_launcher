import 'dart:io';

import 'package:charset_converter/charset_converter.dart';
import 'package:database_repository/src/game_engines/index.dart';
import 'package:path/path.dart' as p;

class RenpyGameEngine extends GameEngineModel {
  RenpyGameEngine()
      : super(
          gameEngineEnum: GameEngineEnum.renpy,
          displayName: "RenPy",
          saveFileExtensions: [".save"],
        );

  @override
  Future<bool> detectGameEngineFromGameFiles(
    List<FileSystemEntity> gameDirContent,
  ) {
    return Future.value(
        gameDirContent.any((element) => p.basename(element.path) == "renpy"));
  }

  @override
  Future<String?> getDefaultSavesPath(
      {required String absoluteGamePath}) async {
    String extracedSaveDir = await _extractSavePath(gamePath: absoluteGamePath);
    String path = p.join(
      "%AppData%",
      "RenPy",
      extracedSaveDir,
    );
    return path;
  }

  Future<String> _extractSavePath({required String gamePath}) async {
    // Find options or script file
    File optionsFile = File(p.join(gamePath, "game", "options.rpy"));
    if (!await optionsFile.exists()) {
      // Options file not found -> fallback script file
      optionsFile = File(p.join(gamePath, "game", "script.rpa"));
      if (!await optionsFile.exists()) {
        // Options file not found -> fallback scripts file
        optionsFile = File(p.join(gamePath, "game", "scripts.rpa"));
        if (!await optionsFile.exists()) {
          // TODO _logger.e("Failed to find options.rpy, script.rpa or scripts.rpa!");
          return Future.error(
              "Failed to find options.rpy, script.rpa or scripts.rpa!");
        }
      }
    }

    // Read file
    // Regex for extraction everything enclosed by double quotes
    RegExp saveDirRegex = RegExp(r'define config\.save_directory = "(.*?)"');
    try {
      String content = await CharsetConverter.decode(
        "windows1252", // ANSI encoding
        await optionsFile.readAsBytes(),
      );
      RegExpMatch? match = saveDirRegex.firstMatch(content);
      if (match == null || match.groupCount == 0 || match.group(1)!.isEmpty) {
        // TODO _logger.e("Failed to extract save dir from file");
        return Future.error(Exception("Failed to extract save dir from file."));
      }
      return match.group(1)!;
    } on CharsetConversionError catch (e) {
      // TODO _logger.e(e.message);
    } /* TODO this exception is a flutter exception
    on PlatformException catch (e) {
      _logger.e(e.message);
    }*/
    return Future.error(Exception("Failed to decode script or config file."));
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
      // ignore the one with -32 suffix
      List<File> non32Exes = exes
          .where((exe) => !p.basename(exe.path).contains("-32.exe"))
          .toList();
      if (non32Exes.length == 1) {
        return non32Exes[0].path;
      }
      // TODO
      /*_logger.w(
        "Unable to determine game exe from list ${exes.map((e) => e.path).join(', ')}",
      );*/
      return null;
    }

    return null;
  }
}
