import 'dart:io';

import 'package:path/path.dart' as p;

// TODO
// Handles all files specific operations.
// All paths starting with / are relative to root gamesBasePath.
// All %AppData%/* files are relative to AppData
class FilesRepository {
  String _rootPath = "";

  // TODO strictly speaking those do not belong here (not required for accessing files)
  String get gamesLauncherDataPath => p.join(
        p.separator,
        ".launcherData",
      );

  String get gamesTempPath => p.join(
        gamesLauncherDataPath,
        ".tmp",
      );

  String get gameAnalyzingPath => p.join(
        gamesTempPath,
        ".analyzing",
      );

  String get gamesMetadataPath => p.join(
        gamesLauncherDataPath,
        "metadata",
      );

  String get gamesUninstalledPath => p.join(
        gamesLauncherDataPath,
        "uninstalled",
      );
  static const String saveProfileDirectoryName = "SaveProfiles";
  static const String gameGuideFileName = "Guide.md";

  FilesRepository({required Stream<String> rootPathStream}) {
    // TODO for some reason doOnData does not receive behaviourSubjects last cached value
    rootPathStream.listen(
      (event) {
        _rootPath = event;
      },
    );
  }

  Directory getDirectory(String directoryPath) {
    if (directoryPath.startsWith(p.separator)) {
      // Remove leading separator, otherwise it will be interpreted as root -> _rootPath is ignored
      String absoluteDirectoryPath =
          p.normalize(p.join(_rootPath, directoryPath.substring(1)));
      if (!isWithinRoot(absoluteDirectoryPath)) {
        throw FileSystemException("Directory is outside the root directory.");
      }
      return Directory(absoluteDirectoryPath);
    } else if (directoryPath.toLowerCase().startsWith("%appdata%")) {
      // TODO handle %AppData%
      final appDataPath = Platform.environment['APPDATA'];
      if (appDataPath == null) {
        throw FileSystemException("Unable to resolve %AppData%.");
      }
      // Used replaceRange due to case sensitivity of replaceAll
      String absoluteDirectoryPath = p.normalize(p.join(_rootPath,
          directoryPath.replaceRange(0, "%AppData%".length, appDataPath)));
      if (!_isWithin(appDataPath, absoluteDirectoryPath)) {
        throw FileSystemException("Directory is outside the root directory.");
      }
      return Directory(absoluteDirectoryPath);
    } else {
      throw FileSystemException("Directory outside supported directory.");
    }
  }

  File getFile(String filePath) {
    // TODO really only if starts with separator?!?!
    // What if .\?! -> perhaps treat normally -> just return File(filePath)
    //  -> SUGGESTION: This is only for handling data inside the folder and supported others (like AppData) -> the rest cause exception
    if (filePath.startsWith(p.separator)) {
      // Remove leading separator, otherwise it will be interpreted as root -> _rootPath is ignored
      String absoluteFilePath =
          p.normalize(p.join(_rootPath, filePath.substring(1)));
      if (!isWithinRoot(absoluteFilePath)) {
        throw FileSystemException("File is outside the root directory.");
      }
      return File(absoluteFilePath);
    } else if (filePath.toLowerCase().startsWith("%appdata%")) {
      // TODO handle %AppData%
      final appDataPath = Platform.environment['APPDATA'];
      if (appDataPath == null) {
        throw FileSystemException("Unable to resolve %AppData%.");
      }
      // Used replaceRange due to case sensitivity of replaceAll
      String absoluteFilePath = p.normalize(p.join(_rootPath,
          filePath.replaceRange(0, "%AppData%".length, appDataPath)));
      if (!_isWithin(appDataPath, absoluteFilePath)) {
        throw FileSystemException("File is outside the root directory.");
      }
      return File(absoluteFilePath);
    } else {
      throw FileSystemException("File outside supported directory.");
    }
  }

  String relativeToRoot(String path) {
    return p.relative(path, from: _rootPath);
  }

  bool isWithinRoot(String absolutePath) {
    return _isWithin(_rootPath, absolutePath);
  }

  bool _isWithin(String rootPath, String absolutePath) {
    String normalizedRoot = p.normalize(rootPath);
    String normalizedPath = p.normalize(absolutePath);
    return normalizedPath.startsWith(normalizedRoot);
  }
}
