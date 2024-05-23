import 'package:bloc/bloc.dart';
import 'package:database_repository/database_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:game_launcher/src/game/add/details_form/models/index.dart';

part 'details_form_event.dart';
part 'details_form_state.dart';

class DetailsFormBloc extends Bloc<DetailsFormEvent, DetailsFormState> {
  DetailsFormBloc({
    required GameDatabaseRepository gameDatabaseRepository,
    required GenreDatabaseRepository genreDatabaseRepository,
    required DeveloperDatabaseRepository developerDatabaseRepository,
  })  : _gameDatabaseRepository = gameDatabaseRepository,
        _genreDatabaseRepository = genreDatabaseRepository,
        _developerDatabaseRepository = developerDatabaseRepository,
        super(DetailsFormInitial()) {
    on<DescriptionChanged>(_onDescriptionChanged);
    on<DevelopersChanged>(_onDevelopersChanged);
    on<GenresChanged>(_onGenresChanged);
    on<LanguageChanged>(_onLanguageChanged);
    on<NameChanged>(_onNameChanged);
    on<PrequelChanged>(_onPrequelChanged);
    on<SequelChanged>(_onSequelChanged);
    on<VersionChanged>(_onVersionChanged);
    on<VotingChanged>(_onVotingChanged);
    on<WebsiteChanged>(_onWebsiteChanged);
    on<FormSubmitted>(_onFormSubmitted);
    on<FormLoaded>(_onFormLoaded);

    Future.wait([
      _gameDatabaseRepository.all.first,
      _genreDatabaseRepository.all.first,
      _developerDatabaseRepository.all.first,
    ]).then((values) {
      final games = values[0] as List<GameModel>;
      final genres = values[1] as List<GenreModel>;
      final developers = values[2] as List<DeveloperModel>;

      add(FormLoaded(
        genreModels: genres,
        developerModels: developers,
        gameModels: games,
      ));
    });
  }

  final GameDatabaseRepository _gameDatabaseRepository;
  final GenreDatabaseRepository _genreDatabaseRepository;
  final DeveloperDatabaseRepository _developerDatabaseRepository;

  _onDescriptionChanged(
    DescriptionChanged event,
    Emitter<DetailsFormState> emit,
  ) {
    final description = Description.dirty(event.description);
    emit(state.copyWith(
      description: description,
      isValid: _validateWithState(description: description),
    ));
  }

  bool _validateWithState({
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
  }) {
    return Formz.validate([
      description ?? state.description,
      developers ?? state.developers,
      genres ?? state.genres,
      language ?? state.language,
      name ?? state.name,
      prequel ?? state.prequel,
      sequel ?? state.sequel,
      version ?? state.version,
      voting ?? state.voting,
      website ?? state.website,
    ]);
  }

  _onDevelopersChanged(
    DevelopersChanged event,
    Emitter<DetailsFormState> emit,
  ) {
    final developers = Developers.dirty(event.developers);
    emit(state.copyWith(
      developers: developers,
      isValid: _validateWithState(developers: developers),
    ));
  }

  _onGenresChanged(
    GenresChanged event,
    Emitter<DetailsFormState> emit,
  ) {
    final genres = Genres.dirty(event.genres);
    emit(state.copyWith(
      genres: genres,
      isValid: _validateWithState(genres: genres),
    ));
  }

  _onLanguageChanged(
    LanguageChanged event,
    Emitter<DetailsFormState> emit,
  ) {
    final language = Language.dirty(event.language);
    emit(state.copyWith(
      language: language,
      isValid: _validateWithState(language: language),
    ));
  }

  _onNameChanged(
    NameChanged event,
    Emitter<DetailsFormState> emit,
  ) {
    final name = Name.dirty(event.name);
    emit(state.copyWith(
      name: name,
      isValid: _validateWithState(name: name),
    ));
  }

  _onPrequelChanged(
    PrequelChanged event,
    Emitter<DetailsFormState> emit,
  ) {
    final prequel = Prequel.dirty(event.prequel);
    emit(state.copyWith(
      prequel: prequel,
      isValid: _validateWithState(prequel: prequel),
    ));
  }

  _onSequelChanged(
    SequelChanged event,
    Emitter<DetailsFormState> emit,
  ) {
    final sequel = Sequel.dirty(event.sequel);
    emit(state.copyWith(
      sequel: sequel,
      isValid: _validateWithState(sequel: sequel),
    ));
  }

  _onVersionChanged(
    VersionChanged event,
    Emitter<DetailsFormState> emit,
  ) {
    final version = Version.dirty(event.version);
    emit(state.copyWith(
      version: version,
      isValid: _validateWithState(version: version),
    ));
  }

  _onVotingChanged(
    VotingChanged event,
    Emitter<DetailsFormState> emit,
  ) {
    final voting = Voting.dirty(event.voting);
    emit(state.copyWith(
      voting: voting,
      isValid: _validateWithState(voting: voting),
    ));
  }

  _onWebsiteChanged(
    WebsiteChanged event,
    Emitter<DetailsFormState> emit,
  ) {
    final website = Website.dirty(event.website);
    emit(state.copyWith(
      website: website,
      isValid: _validateWithState(website: website),
    ));
  }

  _onFormSubmitted(
    FormSubmitted event,
    Emitter<DetailsFormState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      try {
        // Using ! is save due to these attributes being required
        // and thus triggering validation error -> state.isValid == false
        _gameDatabaseRepository.updateDetailsForm(
          description: state.description.value,
          developerIds: state.developers.value.map((e) => e.id).toList(),
          genreIds: state.genres.value.map((e) => e.id).toList(),
          language: state.language.value,
          name: state.name.value!,
          prequelId: state.prequel.value?.id,
          sequelId: state.sequel.value?.id,
          version: state.version.value!,
          voting: state.voting.value,
          website: state.website.value,
        );
        emit(state.copyWith(status: FormzSubmissionStatus.success));
      } catch (_) {
        emit(state.copyWith(status: FormzSubmissionStatus.failure));
      }
    }
  }

  _onFormLoaded(
    FormLoaded event,
    Emitter<DetailsFormState> emit,
  ) async {
    emit(DetailsFormLoaded(
      genreModels: event.genreModels,
      developerModels: event.developerModels,
      gameModels: event.gameModels,
    ));
    // Wait a few seconds to build the form and then emit initial values
    // in order to trigger listeners that set the initial value of TextFields
    await Future.delayed(const Duration(milliseconds: 500));
    final name = Name.dirty(_gameDatabaseRepository.creationGame.name);
    final version = Version.dirty(_gameDatabaseRepository.creationGame.version);
    emit(state.copyWith(
      name: name,
      version: version,
      isValid: _validateWithState(
        name: name,
        version: version,
      ),
    ));
  }
}
