part of 'library_bloc.dart';

sealed class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object> get props => [];
}

final class LibraryGamesUpdated extends LibraryEvent {
  const LibraryGamesUpdated({required this.games});

  final List<GameModel> games;

  @override
  List<Object> get props => [
        ...super.props,
        games,
      ];
}

final class LibrarySortingChanged extends LibraryEvent {
  const LibrarySortingChanged({required this.sorting});

  final Sorting sorting;

  @override
  List<Object> get props => [
        ...super.props,
        sorting,
      ];
}
