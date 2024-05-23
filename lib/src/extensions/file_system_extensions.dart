import 'dart:io';

import 'package:game_launcher/src/extensions/directory_extensions.dart';
import 'package:progress_repository/progress_repository.dart';

extension FileSystemEntityCopy on FileSystemEntity {
  Future<FileSystemEntity> copy(
    String destination, {
    bool recursive = false,
    Function(Progress progress)? onProgressUpdate,
  }) {
    if (this is File) {
      return (this as File).copy(destination);
    } else if (this is Directory) {
      return (this as Directory).copyTo(
        Directory(destination),
        recursive: recursive,
        onProgressUpdate: onProgressUpdate,
      );
    } else {
      return Future.error("Not Implemented!");
    }
  }
}
