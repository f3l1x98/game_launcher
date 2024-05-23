part of 'details_form_bloc.dart';

class DetailsFormState extends Equatable {
  const DetailsFormState({
    this.status = FormzSubmissionStatus.initial,
    this.description = const Description.pure(),
    this.developers = const Developers.pure(),
    this.genres = const Genres.pure(),
    this.language = const Language.pure(),
    this.name = const Name.pure(),
    this.prequel = const Prequel.pure(),
    this.sequel = const Sequel.pure(),
    this.version = const Version.pure(),
    this.voting = const Voting.pure(),
    this.website = const Website.pure(),
    this.isValid = false,
  });

  final FormzSubmissionStatus status;
  final Description description;
  final Developers developers;
  final Genres genres;
  final Language language;
  final Name name;
  final Prequel prequel;
  final Sequel sequel;
  final Version version;
  final Voting voting;
  final Website website;
  final bool isValid;

  DetailsFormState copyWith({
    FormzSubmissionStatus? status,
    Description? description,
    Developers? developers,
    Genres? genres,
    Language? language,
    Name? name,
    Prequel? prequel,
    Sequel? sequel,
    Version? version,
    Voting? voting,
    Website? website,
    bool? isValid,
  }) {
    return DetailsFormState(
      status: status ?? this.status,
      description: description ?? this.description,
      developers: developers ?? this.developers,
      genres: genres ?? this.genres,
      language: language ?? this.language,
      name: name ?? this.name,
      prequel: prequel ?? this.prequel,
      sequel: sequel ?? this.sequel,
      version: version ?? this.version,
      voting: voting ?? this.voting,
      website: website ?? this.website,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object> get props => [
        status,
        description,
        developers,
        genres,
        language,
        name,
        prequel,
        sequel,
        version,
        voting,
        website,
        isValid,
      ];
}

final class DetailsFormInitial extends DetailsFormState {}

final class DetailsFormLoaded extends DetailsFormState {
  const DetailsFormLoaded({
    super.status,
    super.description,
    super.developers,
    super.genres,
    super.language,
    super.name,
    super.prequel,
    super.sequel,
    super.version,
    super.voting,
    super.website,
    super.isValid,
    required this.genreModels,
    required this.developerModels,
    required this.gameModels,
  });
  DetailsFormLoaded.fromBase({
    required DetailsFormState base,
    required this.genreModels,
    required this.developerModels,
    required this.gameModels,
  }) : super(
          status: base.status,
          description: base.description,
          developers: base.developers,
          genres: base.genres,
          language: base.language,
          name: base.name,
          prequel: base.prequel,
          sequel: base.sequel,
          version: base.version,
          voting: base.voting,
          website: base.website,
          isValid: base.isValid,
        );

  final List<GenreModel> genreModels;
  final List<DeveloperModel> developerModels;
  final List<GameModel> gameModels;

  @override
  DetailsFormLoaded copyWith({
    FormzSubmissionStatus? status,
    Description? description,
    Developers? developers,
    Genres? genres,
    Language? language,
    Name? name,
    Prequel? prequel,
    Sequel? sequel,
    Version? version,
    Voting? voting,
    Website? website,
    bool? isValid,
    List<GenreModel>? genreModels,
    List<DeveloperModel>? developerModels,
    List<GameModel>? gameModels,
  }) {
    return DetailsFormLoaded(
      status: status ?? this.status,
      description: description ?? this.description,
      developers: developers ?? this.developers,
      genres: genres ?? this.genres,
      language: language ?? this.language,
      name: name ?? this.name,
      prequel: prequel ?? this.prequel,
      sequel: sequel ?? this.sequel,
      version: version ?? this.version,
      voting: voting ?? this.voting,
      website: website ?? this.website,
      isValid: isValid ?? this.isValid,
      genreModels: genreModels ?? this.genreModels,
      developerModels: developerModels ?? this.developerModels,
      gameModels: gameModels ?? this.gameModels,
    );
  }

  @override
  List<Object> get props => [
        ...super.props,
        genreModels,
        developerModels,
        gameModels,
      ];
}
