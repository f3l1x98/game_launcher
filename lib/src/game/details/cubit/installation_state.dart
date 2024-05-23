part of 'installation_cubit.dart';

sealed class InstallationState extends Equatable {
  const InstallationState();

  @override
  List<Object> get props => [];
}

final class InstallationIdle extends InstallationState {}

final class InstallationRunning extends InstallationState {
  const InstallationRunning({required this.progressId});

  final String progressId;

  @override
  List<Object> get props => [progressId];
}

final class InstallationFailed extends InstallationState {
  const InstallationFailed({required this.error});

  final String error;

  @override
  List<Object> get props => [error];
}
