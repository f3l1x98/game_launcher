import 'dart:io';

import 'package:progress_repository/progress_repository.dart';
import 'package:path/path.dart' as p;

extension DirectoryHelper on Directory {
  /// Recursively copies a directory + subdirectories into a target directory.
  /// Similar to Copy-Item in PowerShell.
  Future<Directory> copyTo(
    final Directory destination, {
    bool recursive = false,
    Function(Progress progress)? onProgressUpdate,
  }) async {
    // Create destination
    await destination.create();
    List<FileSystemEntity> entities = await list(recursive: recursive).toList();
    if (onProgressUpdate != null) {
      onProgressUpdate(Progress(max: entities.length));
    }
    int i = 0;
    for (var entity in entities) {
      try {
        if (entity is Directory) {
          var newDirectory = Directory(p.join(
            destination.absolute.path,
            p.relative(entity.path, from: path),
          ));
          await newDirectory.create();
        } else if (entity is File) {
          await entity.copy(p.join(
            destination.path,
            p.relative(entity.path, from: path),
          ));
        }
        if (onProgressUpdate != null) {
          onProgressUpdate(Progress(max: entities.length, current: ++i));
        }
      } catch (e) {
        // TODO LoggerUtils.get().logger.e("Failed to copy ${entity.path}: $e");
      }
    }
    return destination;
  }

  Future<void> clear({
    bool recursive = false,
    Function(Progress progress)? onProgressUpdate,
  }) async {
    List<FileSystemEntity> entities = await list(recursive: false).toList();
    if (onProgressUpdate != null) {
      onProgressUpdate(Progress(max: entities.length));
    }
    int i = 0;
    for (var entity in entities) {
      await entity.delete(recursive: recursive);
      if (onProgressUpdate != null) {
        onProgressUpdate(Progress(max: entities.length, current: ++i));
      }
    }
  }
}
