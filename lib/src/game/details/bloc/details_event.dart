part of 'details_bloc.dart';

sealed class DetailsEvent extends Equatable {
  const DetailsEvent();

  @override
  List<Object> get props => [];
}

final class DetailsLoadedSuccess extends DetailsEvent {
  const DetailsLoadedSuccess({
    required this.game,
    required this.genres,
    required this.developers,
    required this.gameEngine,
  });

  final GameModel game;
  final List<GenreModel> genres;
  final List<DeveloperModel> developers;
  final GameEngineModel gameEngine;

  @override
  List<Object> get props => [
        game,
        genres,
        developers,
        gameEngine,
      ];
}

final class DetailsLoadedGameNotFound extends DetailsEvent {
  const DetailsLoadedGameNotFound();
}

final class DetailsUpdateGame extends DetailsEvent {
  const DetailsUpdateGame({
    required this.game,
  });

  final GameModel game;

  @override
  List<Object> get props => [game];
}

final class DetailsStartGame extends DetailsEvent {}

final class DetailsStopGame extends DetailsEvent {}

final class DetailsGameError extends DetailsEvent {
  const DetailsGameError({required this.message});

  final String message;

  @override
  List<Object> get props => [message];
}

final class DetailsSwitchSaveProfile extends DetailsEvent {
  const DetailsSwitchSaveProfile({required this.newSaveProfile});

  final SaveProfileModel newSaveProfile;

  @override
  List<Object> get props => [newSaveProfile];
}

final class DetailsUpdateFullSave extends DetailsEvent {
  const DetailsUpdateFullSave({required this.fullSave});

  final bool fullSave;

  @override
  List<Object> get props => [fullSave];
}
