part of 'dashboard_bloc.dart';

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

final class DashboardLatestPlayedGamesUpdated extends DashboardEvent {
  const DashboardLatestPlayedGamesUpdated({required this.latestPlayedGames});

  final List<GameModel> latestPlayedGames;

  @override
  List<Object> get props => [
        ...super.props,
        latestPlayedGames,
      ];
}
