import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:progress_data_layer/progress_data_layer.dart' as data_layer;

class Progress extends Equatable {
  final String id;
  final String? name;
  final String? description;
  final int current;
  final int max;

  final Progress? childProgress;

  Progress._({
    required this.id,
    this.current = 0,
    required this.max,
    this.name,
    this.description,
    this.childProgress,
  });

  Progress({
    this.current = 0,
    required this.max,
    this.name,
    this.description,
    this.childProgress,
  }) : id = const Uuid().v4();

  Progress.fromPercentage({
    required int percentage,
    this.name,
    this.description,
    this.childProgress,
  })  : id = const Uuid().v4(),
        max = 100,
        current = percentage;

  Progress.advanceBase({required Progress base, String? newDescription})
      : id = base.id,
        name = base.name,
        description = newDescription ?? base.description,
        current = base.current + 1,
        max = base.max,
        childProgress = base.childProgress;

  static Progress fromDataLayerModel(
    data_layer.Progress dataLayerModel,
  ) {
    return Progress._(
      id: dataLayerModel.id,
      current: dataLayerModel.current,
      max: dataLayerModel.max,
      name: dataLayerModel.name,
      description: dataLayerModel.description,
      childProgress: dataLayerModel.childProgress != null
          ? fromDataLayerModel(dataLayerModel.childProgress!)
          : null,
    );
  }

  data_layer.Progress toDataLayerModel() {
    return data_layer.Progress(
      id: id,
      current: current,
      max: max,
      name: name,
      description: description,
      childProgress: childProgress?.toDataLayerModel(),
    );
  }

  Progress copyWith({
    String? name,
    String? description,
    int? current,
    int? max,
    Progress? childProgress,
  }) {
    return Progress._(
      id: id,
      description: description ?? this.description,
      current: current ?? this.current,
      max: max ?? this.max,
      childProgress: childProgress ?? this.childProgress,
    );
  }

  double get percentage => max <= 0 ? 0.0 : current.toDouble() / max.toDouble();

  bool get running => current < max;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        current,
        max,
        childProgress,
      ];
}
