part of 'details_bloc.dart';

sealed class DetailsState extends Equatable {
  const DetailsState();

  @override
  List<Object> get props => [];
}

final class DetailsInitial extends DetailsState {}

final class DetailsLoaded extends DetailsState {
  const DetailsLoaded({
    required this.game,
    required this.genres,
    required this.developers,
    required this.gameEngine,
    this.isRunning = false,
  });

  final GameModel game;
  final List<GenreModel> genres;
  final List<DeveloperModel> developers;
  final GameEngineModel gameEngine;
  final bool isRunning;

  DetailsLoaded copyWith({
    GameModel? game,
    List<GenreModel>? genres,
    List<DeveloperModel>? developers,
    List<SaveProfileModel>? saveProfiles,
    GameEngineModel? gameEngine,
    LauncherSettings? launcherSettings,
    bool? isRunning,
  }) {
    return DetailsLoaded(
      game: game ?? this.game,
      genres: genres ?? this.genres,
      developers: developers ?? this.developers,
      gameEngine: gameEngine ?? this.gameEngine,
      isRunning: isRunning ?? this.isRunning,
    );
  }

  @override
  List<Object> get props => [
        game,
        genres,
        developers,
        gameEngine,
        isRunning,
      ];
}

final class DetailsNoGame extends DetailsState {}

final class DetailsFailure extends DetailsState {
  const DetailsFailure({
    required this.message,
  });

  final String message;

  DetailsFailure copyWith({String? message}) {
    return DetailsFailure(message: message ?? this.message);
  }

  @override
  List<Object> get props => [message];
}
