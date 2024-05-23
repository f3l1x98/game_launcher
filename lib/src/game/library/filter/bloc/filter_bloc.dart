import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:database_repository/database_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:game_launcher/src/game/library/filter/model/genre_list.dart';
import 'package:game_launcher/src/game/library/filter/model/installed_only.dart';
import 'package:game_launcher/src/game/library/filter/model/search_text.dart';
import 'package:rxdart/rxdart.dart';

part 'filter_event.dart';
part 'filter_state.dart';

class FilterBloc extends Bloc<FilterEvent, FilterState> {
  FilterBloc({
    required GameDatabaseRepository gameDatabaseRepository,
    required GenreDatabaseRepository genreDatabaseRepository,
  })  : _gameDatabaseRepository = gameDatabaseRepository,
        _genreDatabaseRepository = genreDatabaseRepository,
        super(const FilterInitial(
          searchText: SearchText.pure(),
          installedOnly: InstalledOnly.pure(),
          includedGenres: GenreList.pure(),
          excludedGenres: GenreList.pure(),
        )) {
    on<FilterGenresLoaded>(_onFilterGenresLoaded);
    on<FilterSearchTextChanged>(_onFilterSearchTextChanged);
    on<FilterInstalledOnlyChanged>(_onFilterInstalledOnlyChanged);
    on<FilterIncludedGenresChanged>(_onFilterIncludedGenresChanged);
    on<FilterExcludedGenresChanged>(_onFilterExcludedGenresChanged);
    on<FilterSubmitted>(_onFilterSubmitted);
    on<FilterCleared>(_onFilterCleared);

    _genreDatabaseRepository.all.takeUntil(destroy$).listen((event) {
      add(FilterGenresLoaded(event));
    });
  }

  final PublishSubject<bool> destroy$ = PublishSubject<bool>();
  final GameDatabaseRepository _gameDatabaseRepository;
  final GenreDatabaseRepository _genreDatabaseRepository;

  _onFilterGenresLoaded(
    FilterGenresLoaded event,
    Emitter<FilterState> emit,
  ) {
    if (state is FilterInitial) {
      // First time loaded -> set initial values
      final includedGenres = event.genres
          .where((genre) =>
              _gameDatabaseRepository.includedGenreIds.contains(genre.id))
          .toList();
      final excludedGenres = event.genres
          .where((genre) =>
              _gameDatabaseRepository.excludedGenreIds.contains(genre.id))
          .toList();
      emit(FilterLoaded(
        genres: event.genres,
        status: state.status,
        searchText: SearchText.dirty(_gameDatabaseRepository.searchText),
        installedOnly:
            InstalledOnly.dirty(_gameDatabaseRepository.installedOnly),
        includedGenres: GenreList.dirty(includedGenres),
        excludedGenres: GenreList.dirty(excludedGenres),
      ));
    } else {
      emit((state as FilterLoaded).copyWith(
        genres: event.genres,
      ));
    }
  }

  _onFilterSearchTextChanged(
    FilterSearchTextChanged event,
    Emitter<FilterState> emit,
  ) {
    final searchText = SearchText.dirty(event.searchText);
    emit(state.copyWith(searchText: searchText));
    add(FilterSubmitted());
    /*if (state is FilterInitial) {
      emit((state as FilterInitial).copyWith(searchText: searchText));
    } else if (state is FilterLoaded) {
      emit((state as FilterLoaded).copyWith(searchText: searchText));
    }*/
  }

  _onFilterInstalledOnlyChanged(
    FilterInstalledOnlyChanged event,
    Emitter<FilterState> emit,
  ) {
    final installedOnly = InstalledOnly.dirty(event.installedOnly);
    emit(state.copyWith(installedOnly: installedOnly));
    add(FilterSubmitted());
  }

  _onFilterIncludedGenresChanged(
    FilterIncludedGenresChanged event,
    Emitter<FilterState> emit,
  ) {
    final includedGenres = GenreList.dirty(event.genres);
    emit(state.copyWith(includedGenres: includedGenres));
    add(FilterSubmitted());
  }

  _onFilterExcludedGenresChanged(
    FilterExcludedGenresChanged event,
    Emitter<FilterState> emit,
  ) {
    final excludedGenres = GenreList.dirty(event.genres);
    emit(state.copyWith(excludedGenres: excludedGenres));
    add(FilterSubmitted());
  }

  _onFilterSubmitted(
    FilterSubmitted event,
    Emitter<FilterState> emit,
  ) async {
    emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
    try {
      await _gameDatabaseRepository.filter(
        searchText: state.searchText.value,
        installedOnly: state.installedOnly.value,
        includedGenreIds: state.includedGenres.value.map((e) => e.id).toList(),
        excludedGenreIds: state.excludedGenres.value.map((e) => e.id).toList(),
      );
      emit(state.copyWith(status: FormzSubmissionStatus.success));
    } catch (_) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }

  _onFilterCleared(
    FilterCleared event,
    Emitter<FilterState> emit,
  ) async {
    // TODO does not update all filter inputs to be empty
    // -> Switch needs somekind of listener
    emit(state.copyWith(
      status: FormzSubmissionStatus.initial,
      searchText: const SearchText.pure(),
      installedOnly: const InstalledOnly.pure(),
      includedGenres: const GenreList.pure(),
      excludedGenres: const GenreList.pure(),
    ));
    add(FilterSubmitted());
  }

  List<GenreModel> getGenresFromIds(List<int> ids) {
    if (state is FilterLoaded) {
      return (state as FilterLoaded)
          .genres
          .where((genre) => ids.contains(genre.id))
          .toList();
    } else {
      return [];
    }
  }

  @override
  Future<void> close() {
    destroy$.add(true);
    return super.close();
  }
}
