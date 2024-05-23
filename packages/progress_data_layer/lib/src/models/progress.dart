import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class Progress extends Equatable {
  final String id;
  final String? name;
  final String? description;
  final int current;
  final int max;

  final Progress? childProgress;

  Progress({
    required this.id,
    this.current = 0,
    required this.max,
    this.name,
    this.description,
    this.childProgress,
  });

  Progress.generateId({
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
