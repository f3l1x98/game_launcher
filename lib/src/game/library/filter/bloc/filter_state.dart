part of 'filter_bloc.dart';

class FilterState extends Equatable {
  const FilterState({
    this.status = FormzSubmissionStatus.initial,
    this.searchText = const SearchText.pure(),
    this.installedOnly = const InstalledOnly.pure(),
    this.includedGenres = const GenreList.pure(),
    this.excludedGenres = const GenreList.pure(),
  });

  final FormzSubmissionStatus status;
  final SearchText searchText;
  final InstalledOnly installedOnly;
  final GenreList includedGenres;
  final GenreList excludedGenres;

  FilterState copyWith({
    FormzSubmissionStatus? status,
    SearchText? searchText,
    InstalledOnly? installedOnly,
    GenreList? includedGenres,
    GenreList? excludedGenres,
  }) {
    return FilterState(
      status: status ?? this.status,
      searchText: searchText ?? this.searchText,
      installedOnly: installedOnly ?? this.installedOnly,
      includedGenres: includedGenres ?? this.includedGenres,
      excludedGenres: excludedGenres ?? this.excludedGenres,
    );
  }

  bool isPure() {
    return Formz.isPure([
      searchText,
      installedOnly,
      includedGenres,
      excludedGenres,
    ]);
  }

  @override
  List<Object> get props => [
        status,
        searchText,
        installedOnly,
        includedGenres,
        excludedGenres,
      ];
}

final class FilterInitial extends FilterState {
  const FilterInitial({
    super.status,
    super.searchText,
    super.installedOnly,
    super.includedGenres,
    super.excludedGenres,
  });
}

final class FilterLoaded extends FilterState {
  const FilterLoaded({
    required this.genres,
    super.status,
    super.searchText,
    super.installedOnly,
    super.includedGenres,
    super.excludedGenres,
  });

  final List<GenreModel> genres;

  @override
  FilterLoaded copyWith({
    List<GenreModel>? genres,
    FormzSubmissionStatus? status,
    SearchText? searchText,
    InstalledOnly? installedOnly,
    GenreList? includedGenres,
    GenreList? excludedGenres,
  }) {
    return FilterLoaded(
      genres: genres ?? this.genres,
      status: status ?? this.status,
      searchText: searchText ?? this.searchText,
      installedOnly: installedOnly ?? this.installedOnly,
      includedGenres: includedGenres ?? this.includedGenres,
      excludedGenres: excludedGenres ?? this.excludedGenres,
    );
  }

  @override
  List<Object> get props => [...super.props, genres];
}
