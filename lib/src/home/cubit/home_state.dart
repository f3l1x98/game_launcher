part of 'home_cubit.dart';

final class HomeState extends Equatable {
  const HomeState({required this.currentProgresses});

  final List<Progress> currentProgresses;

  bool get hasCurrentProgress => currentProgresses.isNotEmpty;

  HomeState copyWith({
    List<Progress>? currentProgresses,
  }) {
    return HomeState(
      currentProgresses: currentProgresses ?? this.currentProgresses,
    );
  }

  @override
  List<Object> get props => [currentProgresses];
}
