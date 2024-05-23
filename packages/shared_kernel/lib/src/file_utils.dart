import 'dart:io';
import 'package:path/path.dart' as p;

Future<List<FileSystemEntity>> getAllFilesWithExtension({
  required String path,
  List<String> extensions = const [],
}) async {
  try {
    final List<FileSystemEntity> entities =
        await Directory(path).list().toList();
    if (extensions.isEmpty) {
      return entities.toList();
    } else {
      return entities
          .whereType<File>()
          // Copy files with extension or all if no extensions given
          .where((element) => extensions.contains(p.extension(element.path)))
          .toList();
    }
  } catch (e) {
    throw const FileSystemException("Failed to list files in directory.");
  }
}
