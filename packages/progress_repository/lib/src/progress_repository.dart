import 'package:progress_data_layer/progress_data_layer.dart' hide Progress;
import 'package:progress_repository/src/abstract_progress_repository.dart';
import 'package:progress_repository/src/models/progress.dart';

class ProgressRepository extends AbstractProgressRepository {
  final ProgressDataLayer _progressDataLayer;

  ProgressRepository({required ProgressDataLayer progressDataLayer})
      : _progressDataLayer = progressDataLayer;

  bool get hasRunningProgress => _progressDataLayer.hasRunningProgress;

  bool hasRunningProgressWithId(String progressId) =>
      _progressDataLayer.hasRunningProgressWithId(progressId);

  @override
  Stream<List<Progress>> get progresses =>
      _progressDataLayer.progresses.map((event) => event
          .map((dataLayerProgess) =>
              Progress.fromDataLayerModel(dataLayerProgess))
          .toList());

  @override
  upsertProgress(Progress progress) {
    _progressDataLayer.upsertProgress(progress.toDataLayerModel());
  }
}
