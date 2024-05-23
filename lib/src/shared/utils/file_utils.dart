import 'dart:io';
import 'package:path/path.dart' as p;

Future<Directory> removeWrapperDirectories({
  required Directory dir,
  required List<String> archiveExtensions,
}) async {
  // Get all directories and non archive files
  List<FileSystemEntity> gameTmpDirContent =
      await dir.list().where((fileSystemEntity) {
    if (fileSystemEntity is File) {
      return !archiveExtensions.contains(p.extension(fileSystemEntity.path));
    }
    return true;
  }).toList();
  // Default assumption: dir ist NOT a wrapper dir (contains game files)
  Directory rootDir = dir;
  // dir only contains one directory -> is a wrapper dir -> copy content of wrapped dir
  // TODO IMPROVE THIS CHECK (after all could also contain a txt containing download link or a cover image)
  if (gameTmpDirContent.length == 1 && gameTmpDirContent[0] is Directory) {
    // Recursively check for wrapper dir in wrapper dir
    rootDir = await removeWrapperDirectories(
      dir: gameTmpDirContent[0] as Directory,
      archiveExtensions: archiveExtensions,
    );
  }
  return rootDir;
}
