part of 'add_cubit.dart';

sealed class AddState extends Equatable {
  const AddState();

  @override
  List<Object> get props => [];
}

final class AddInitial extends AddState {}

final class AddAnalysing extends AddState {
  const AddAnalysing({required this.archivingPid});

  final int archivingPid;

  @override
  List<Object> get props => [archivingPid];
}

final class AddAnalysisUnknownEngine extends AddState {}

final class AddAnalysisUnityEngine extends AddState {}

final class AddAnalysisFailed extends AddState {
  const AddAnalysisFailed({required this.error});

  final String error;

  @override
  List<Object> get props => [error];
}

final class AddForms extends AddState {
  const AddForms({required this.activeStepperIndex});

  final int activeStepperIndex;

  AddForms copyWith({
    int? activeStepperIndex,
  }) {
    return AddForms(
      activeStepperIndex: activeStepperIndex ?? this.activeStepperIndex,
    );
  }

  @override
  List<Object> get props => [activeStepperIndex];
}
