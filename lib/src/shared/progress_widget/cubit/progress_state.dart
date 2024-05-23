part of 'progress_cubit.dart';

final class ProgressState extends Equatable {
  const ProgressState({required this.currentProgresses});

  final List<Progress> currentProgresses;

  bool get hasCurrentProgress => currentProgresses.isNotEmpty;

  ProgressState copyWith({
    List<Progress>? currentProgresses,
  }) {
    return ProgressState(
      currentProgresses: currentProgresses ?? this.currentProgresses,
    );
  }

  @override
  List<Object> get props => [currentProgresses];
}
