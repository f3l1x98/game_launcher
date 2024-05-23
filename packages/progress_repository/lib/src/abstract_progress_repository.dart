import 'package:progress_repository/src/models/progress.dart';

abstract class AbstractProgressRepository {
  Stream<List<Progress>> get progresses;

  upsertProgress(Progress progress);
}
