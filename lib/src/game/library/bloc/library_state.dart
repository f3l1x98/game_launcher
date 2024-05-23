part of 'library_bloc.dart';

class LibraryState extends Equatable {
  const LibraryState({this.sorting = Sorting.alphabeticalAsc});

  final Sorting sorting;

  LibraryState copyWith({
    Sorting? sorting,
  }) {
    return LibraryState(
      sorting: sorting ?? this.sorting,
    );
  }

  @override
  List<Object> get props => [sorting];
}

final class LibraryInitial extends LibraryState {
  const LibraryInitial({super.sorting});
}

final class LibraryLoaded extends LibraryState {
  const LibraryLoaded({super.sorting, required this.games});

  final List<GameModel> games;

  @override
  LibraryLoaded copyWith({
    Sorting? sorting,
    List<GameModel>? games,
  }) {
    return LibraryLoaded(
      sorting: sorting ?? this.sorting,
      games: games ?? this.games,
    );
  }

  @override
  List<Object> get props => [...super.props, games];
}
