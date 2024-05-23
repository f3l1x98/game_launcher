part of 'filter_bloc.dart';

sealed class FilterEvent extends Equatable {
  const FilterEvent();

  @override
  List<Object> get props => [];
}

final class FilterGenresLoaded extends FilterEvent {
  const FilterGenresLoaded(this.genres);

  final List<GenreModel> genres;

  @override
  List<Object> get props => [genres];
}

final class FilterSearchTextChanged extends FilterEvent {
  const FilterSearchTextChanged(this.searchText);

  final String searchText;

  @override
  List<Object> get props => [searchText];
}

final class FilterInstalledOnlyChanged extends FilterEvent {
  const FilterInstalledOnlyChanged(this.installedOnly);

  final bool installedOnly;

  @override
  List<Object> get props => [installedOnly];
}

final class FilterIncludedGenresChanged extends FilterEvent {
  const FilterIncludedGenresChanged(this.genres);

  final List<GenreModel> genres;

  @override
  List<Object> get props => [genres];
}

final class FilterExcludedGenresChanged extends FilterEvent {
  const FilterExcludedGenresChanged(this.genres);

  final List<GenreModel> genres;

  @override
  List<Object> get props => [genres];
}

final class FilterSubmitted extends FilterEvent {}

final class FilterCleared extends FilterEvent {}
