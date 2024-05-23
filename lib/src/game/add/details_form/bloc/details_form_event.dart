part of 'details_form_bloc.dart';

sealed class DetailsFormEvent extends Equatable {
  const DetailsFormEvent();

  @override
  List<Object> get props => [];
}

final class FormLoaded extends DetailsFormEvent {
  const FormLoaded({
    required this.genreModels,
    required this.developerModels,
    required this.gameModels,
  });

  final List<GenreModel> genreModels;
  final List<DeveloperModel> developerModels;
  final List<GameModel> gameModels;

  @override
  List<Object> get props => [
        genreModels,
        developerModels,
        gameModels,
      ];
}

final class FormSubmitted extends DetailsFormEvent {}

final class DescriptionChanged extends DetailsFormEvent {
  const DescriptionChanged({required this.description});

  final String description;

  @override
  List<Object> get props => [description];
}

final class DevelopersChanged extends DetailsFormEvent {
  const DevelopersChanged({required this.developers});

  final List<DeveloperModel> developers;

  @override
  List<Object> get props => [developers];
}

final class GenresChanged extends DetailsFormEvent {
  const GenresChanged({required this.genres});

  final List<GenreModel> genres;

  @override
  List<Object> get props => [genres];
}

final class LanguageChanged extends DetailsFormEvent {
  const LanguageChanged({required this.language});

  final LanguageEnum language;

  @override
  List<Object> get props => [language];
}

final class NameChanged extends DetailsFormEvent {
  const NameChanged({required this.name});

  final String name;

  @override
  List<Object> get props => [name];
}

final class PrequelChanged extends DetailsFormEvent {
  const PrequelChanged({required this.prequel});

  final GameModel? prequel;

  @override
  List<Object> get props => [];
}

final class SequelChanged extends DetailsFormEvent {
  const SequelChanged({required this.sequel});

  final GameModel? sequel;

  @override
  List<Object> get props => [];
}

final class VersionChanged extends DetailsFormEvent {
  const VersionChanged({required this.version});

  final String version;

  @override
  List<Object> get props => [version];
}

final class VotingChanged extends DetailsFormEvent {
  const VotingChanged({required this.voting});

  final int voting;

  @override
  List<Object> get props => [voting];
}

final class WebsiteChanged extends DetailsFormEvent {
  const WebsiteChanged({required this.website});

  final String website;

  @override
  List<Object> get props => [website];
}
