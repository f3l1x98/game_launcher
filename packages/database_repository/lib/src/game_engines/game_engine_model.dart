import 'dart:io';

import 'package:database_repository/src/game_engines/game_engine_enum.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:shared_kernel/shared_kernel.dart';
import 'package:path/path.dart' as p;

abstract class GameEngineModel extends Equatable {
  final GameEngineEnum gameEngineEnum;
  final String displayName;
  final List<String> saveFileExtensions;
  final List<String> ignoredExes;

  GameEngineModel({
    required this.gameEngineEnum,
    required this.displayName,
    required this.saveFileExtensions,
    this.ignoredExes = const [],
  });

  Future<String?> getDefaultSavesPath({required String absoluteGamePath});
  Future<String?> getGameExecutableAbsolutePath({String? absoluteGamePath});
  Future<bool> detectGameEngineFromGameFiles(
    List<FileSystemEntity> gameFiles,
  );

  @protected
  Future<List<File>> getAllExes(String absoluteGamePath) async {
    List<File> allExes = (await getAllFilesWithExtension(
      path: absoluteGamePath,
      extensions: [".exe"],
    ))
        .whereType<File>()
        .toList();
    if (ignoredExes.isEmpty) {
      return allExes;
    }
    return allExes
        .where((exe) => !ignoredExes.any((ignoredExe) =>
            ignoredExe.toLowerCase() == p.basename(exe.path).toLowerCase()))
        .toList();
  }

  @override
  List<Object?> get props => [gameEngineEnum];
}
