import 'dart:io';

import 'package:files_repository/src/archives/models/archiving_progress_data.dart';
import 'package:files_repository/src/archives/archivers/archiver.dart';
import 'package:shared_kernel/shared_kernel.dart';
import 'package:win32_registry/win32_registry.dart';
import 'package:path/path.dart' as p;

class SevenZipArchiver extends Archiver {
  @override
  List<String> get supportedArchiveExtensions => [
        ".zip",
        ".rar",
        ".7z",
      ];

  late String _archiveProgramDirectoryPath;

  SevenZipArchiver() {
    _archiveProgramDirectoryPath = get7zipDirectoryPath();
  }

  // TODO store in settings like before?!?!
  // -> how?
  // -> pro: less access to regestry
  // -> con: does not update in case 7Zip gets reinstalled somewhere else
  String get7zipDirectoryPath() {
    final uninstallKey = Registry.openPath(
      RegistryHive.localMachine,
      path: r'Software\Microsoft\Windows\CurrentVersion\Uninstall',
    );
    // Search for 7-Zip subKey
    final subKeyNames = List.from(uninstallKey.subkeyNames);
    uninstallKey.close();
    if (!subKeyNames.contains("7-Zip")) {
      throw ProgramNotInstalledException("7-Zip not installed!");
    }

    // Get 7-Zip subKey
    final zipKey = Registry.openPath(
      RegistryHive.localMachine,
      path: r'Software\Microsoft\Windows\CurrentVersion\Uninstall\7-Zip',
    );
    // Get InstallLocation value
    String? programDirectory = zipKey.getValueAsString("InstallLocation");
    zipKey.close();
    if (programDirectory == null) {
      throw ProgramNotInstalledException("7-Zip location not found!");
    }
    // Assert exists
    if (!Directory(programDirectory).existsSync()) {
      throw ProgramNotInstalledException("7-Zip location does not exist!");
    }
    return programDirectory;
  }

  @override
  Future<Process> extract(
    String archivePath,
    String destinationPath, {
    Function(ArchivingProgressData progress)? onProgressChanged,
  }) async {
    return ProgramExecutor.execute(
      p.join(_archiveProgramDirectoryPath, "7z.exe"),
      // TODO not sure if -r for recursive AND NOT SURE IF x INSTEAD OF e?!?!?
      args: [
        "x",
        archivePath,
        "-bsp1", // Redirect progress information to stdout
        "-aoa", // override mode: replace
        "-r", // recursive
        '-o$destinationPath',
      ],
      onStdoutData: onProgressChanged != null
          ? _parseArchiveProgress(onProgressChanged)
          : null,
    );
  }

  Function(String event) _parseArchiveProgress(
    Function(ArchivingProgressData progress) onProgressChanged,
  ) {
    return (event) {
      if (event.isEmpty) return;
      //   0%
      //  94% 2734 - Archive Folder\nw.dll
      final eventTrimmed = event.trim();
      final percentIndex = eventTrimmed.indexOf('%');
      int separatorIndex = eventTrimmed.indexOf('-'); // '-' in case of extract
      if (separatorIndex < 0) {
        separatorIndex = eventTrimmed.indexOf('+'); // '+' in case of archive
      }

      if (percentIndex >= 0 && separatorIndex >= 0) {
        final percentageStr = eventTrimmed.substring(0, percentIndex);
        final file = eventTrimmed.substring(separatorIndex + 1).trim();

        onProgressChanged(ArchivingProgressData(
          percentage: int.tryParse(percentageStr) ?? 0,
          filename: file,
        ));
      }
    };
  }

  @override
  Future<Process> archive(
    List<String> filePaths,
    String archivePath, {
    Function(ArchivingProgressData progress)? onProgressChanged,
  }) async {
    // https://axelstudios.github.io/7z/#!/
    return ProgramExecutor.execute(
      p.join(_archiveProgramDirectoryPath, "7z.exe"),
      args: [
        "a",
        "-tzip", // use zip format
        "-bsp1", // Redirect progress information to stdout
        "-mx9", // Ultra compression level
        "-mmt16", // 16 CPU Threads
        archivePath,
        ...filePaths,
      ],
      onStdoutData: onProgressChanged != null
          ? _parseArchiveProgress(onProgressChanged)
          : null,
    );
  }
}

class ProgramNotInstalledException implements Exception {
  final String message;

  ProgramNotInstalledException(this.message);
}
