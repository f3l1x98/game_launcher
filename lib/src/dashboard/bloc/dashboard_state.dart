part of 'dashboard_bloc.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

final class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

final class DashboardLoaded extends DashboardState {
  final List<GameModel> latestPlayedGames;

  const DashboardLoaded({required this.latestPlayedGames});

  DashboardLoaded copyWith({
    List<GameModel>? latestPlayedGames,
  }) {
    return DashboardLoaded(
      latestPlayedGames: latestPlayedGames ?? this.latestPlayedGames,
    );
  }

  @override
  List<Object> get props => [latestPlayedGames];
}
