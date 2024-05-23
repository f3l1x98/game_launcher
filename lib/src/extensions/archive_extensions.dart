import 'package:files_repository/files_repository.dart';
import 'package:progress_repository/progress_repository.dart';

extension ToProgress on ArchivingProgressData {
  Progress toProgress() {
    return Progress.fromPercentage(
      percentage: percentage,
      description: filename,
    );
  }
}
