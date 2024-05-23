part of 'section_cubit.dart';

final class SectionState extends Equatable {
  const SectionState({
    required this.prevButtonEnabled,
    required this.nextButtonEnabled,
  });

  final bool prevButtonEnabled;
  final bool nextButtonEnabled;

  SectionState copyWith({
    bool? prevButtonEnabled,
    bool? nextButtonEnabled,
  }) {
    return SectionState(
      prevButtonEnabled: prevButtonEnabled ?? this.prevButtonEnabled,
      nextButtonEnabled: nextButtonEnabled ?? this.nextButtonEnabled,
    );
  }

  @override
  List<Object> get props => [prevButtonEnabled, nextButtonEnabled];
}
