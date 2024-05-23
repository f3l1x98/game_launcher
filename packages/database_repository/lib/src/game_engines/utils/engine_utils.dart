import 'dart:io';

import 'package:path/path.dart' as p;

String? containsExe(List<File> exes, String exeFileName) {
  int gameExeIndex = exes.indexWhere(
      (exe) => p.basename(exe.path).toLowerCase() == exeFileName.toLowerCase());
  if (gameExeIndex >= 0) {
    return exes[gameExeIndex].path;
  }
  return null;
}
