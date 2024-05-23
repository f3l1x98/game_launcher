import 'dart:io';

import 'package:files_repository/src/archives/models/archiving_progress_data.dart';

abstract class Archiver {
  List<String> get supportedArchiveExtensions;

  Future<Process> extract(
    String archivePath,
    String destinationPath, {
    Function(ArchivingProgressData progress)? onProgressChanged,
  });
  Future<Process> archive(
    List<String> filePaths,
    String archivePath, {
    Function(ArchivingProgressData progress)? onProgressChanged,
  });
}
