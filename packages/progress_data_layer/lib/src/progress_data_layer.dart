import 'package:progress_data_layer/progress_data_layer.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

class ProgressDataLayer {
  final BehaviorSubject<List<Progress>> _progresses$ =
      BehaviorSubject<List<Progress>>();

  Stream<List<Progress>> get progresses => _progresses$.stream;

  bool get hasRunningProgress =>
      _progresses$.hasValue &&
      _progresses$.valueOrNull!.any((progress) => progress.running);

  bool hasRunningProgressWithId(String progressId) =>
      hasRunningProgress &&
      (_progresses$.valueOrNull!
              .firstWhereOrNull((progress) => progress.id == progressId)
              ?.running ??
          false);

  upsertProgress(Progress progress) {
    final currentProgresses = _progresses$.valueOrNull ?? [];

    final currentProgressIndex =
        currentProgresses.indexWhere((element) => element.id == progress.id);
    final isInsert = currentProgressIndex < 0;

    if (isInsert) {
      currentProgresses.add(progress);
    } else if (!progress.running) {
      currentProgresses.removeAt(currentProgressIndex);
    } else {
      currentProgresses.replaceRange(
        currentProgressIndex,
        currentProgressIndex + 1,
        [progress],
      );
    }
    _progresses$.sink.add(currentProgresses);
  }
}
