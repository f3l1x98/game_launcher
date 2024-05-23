import 'dart:io';

import 'package:files_repository/src/archives/archiving_exception.dart';
import 'package:files_repository/src/archives/models/archiving_process.dart';
import 'package:files_repository/src/archives/models/archiving_progress_data.dart';
import 'package:files_repository/src/archives/archivers/archiver.dart';
import 'package:path/path.dart' as p;

// TODO if necessary to access files directly -> extend FilesRepository
class ArchivesRepository {
  final Archiver _archiver;

  ArchivesRepository(Archiver archiver) : _archiver = archiver;

  // TODO use Stream to notify of new running archiving processes?
  //  -> PROBABLY NOT NECESSARY: new processes will be discovered due to new progress, which is the only interesting data
  final Map<int, Process> _currentArchivingProcessMap =
      <int, Process>{}; // pid to process

  List<String> get supportedArchiveExtensions =>
      _archiver.supportedArchiveExtensions;

  void killAllArchivingProcesses() {
    for (var pid in _currentArchivingProcessMap.keys) {
      _currentArchivingProcessMap.remove(pid)?.kill();
    }
  }

  bool killArchivingProcess(int pid) {
    if (_currentArchivingProcessMap.containsKey(pid)) {
      return _currentArchivingProcessMap.remove(pid)!.kill();
    }
    return true;
  }

  Future<ArchivingProcess> extractArchive({
    required File archiveFile,
    required Directory destination,
    bool createArchiveDirectory = false,
    Function(ArchivingProgressData progress)? onProgressChanged,
  }) async {
    ArchivingProgressData progress = ArchivingProgressData(
      percentage: 0,
      filename: "",
    );
    if (onProgressChanged != null) onProgressChanged(progress);
    // Assert supported archive
    final extension = p.extension(archiveFile.path);
    if (!_archiver.supportedArchiveExtensions.contains(extension)) {
      throw ArchivingException("Unsupported archive $extension");
    }
    // Assert archive exists
    if (!(await archiveFile.exists())) {
      throw ArchivingException(
        "Archive ${archiveFile.path} does not exist!",
      );
    }

    String absoluteDestinationPath = destination.absolute.path;

    // Start extraction process
    var process = await _archiver.extract(
      archiveFile.path,
      absoluteDestinationPath,
      onProgressChanged: (archiveProgress) {
        progress = archiveProgress;
        if (onProgressChanged != null) {
          onProgressChanged(progress);
        }
      },
    );
    _currentArchivingProcessMap[process.pid] = process;
    return ArchivingProcess(
        pid: process.pid,
        archivingFuture: process.exitCode.then((value) {
          _currentArchivingProcessMap.remove(process.pid);
          return absoluteDestinationPath;
        }));
  }

  Future<ArchivingProcess> archiveDirectory({
    required Directory directory,
    required Directory archiveDestination,
    String? archiveFileName,
    bool includeBaseDirectory = false,
    Function(ArchivingProgressData progress)? onProgressChanged,
  }) async {
    ArchivingProgressData progress = ArchivingProgressData(
      percentage: 0,
      filename: "",
    );
    if (onProgressChanged != null) onProgressChanged(progress);
    // Assert supported archive
    if (archiveFileName != null) {
      final extension = p.extension(archiveFileName);
      if (!_archiver.supportedArchiveExtensions.contains(extension)) {
        throw ArchivingException("Unsupported archive $extension");
      }
    }
    // Assert directory to be archive exists
    if (!(await directory.exists())) {
      throw ArchivingException(
        "Directory ${directory.path} does not exist.",
      );
    }
    // Delete existing archive if exists
    String archiveTargetPath = p.join(
      archiveDestination.path,
      "${archiveFileName != null ? p.basenameWithoutExtension(archiveFileName) : p.basename(directory.path)}.zip",
    );
    final File archiveTarget = File(archiveTargetPath);
    if (await archiveTarget.exists()) {
      await archiveTarget.delete();
    }

    // Start archiving process
    String toArchive =
        includeBaseDirectory ? directory.path : p.join(directory.path, "*");
    var process = await _archiver.archive(
      [toArchive],
      archiveTargetPath,
      onProgressChanged: (archiveProgress) {
        progress = archiveProgress;
        if (onProgressChanged != null) {
          onProgressChanged(progress);
        }
      },
    );
    _currentArchivingProcessMap[process.pid] = process;

    return ArchivingProcess(
        pid: process.pid,
        archivingFuture: process.exitCode.then((value) {
          _currentArchivingProcessMap.remove(process.pid);
          return archiveTargetPath;
        }));
  }
}
