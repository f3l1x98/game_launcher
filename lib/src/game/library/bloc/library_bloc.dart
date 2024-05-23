import 'package:bloc/bloc.dart';
import 'package:database_repository/database_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

part 'library_event.dart';
part 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc({required GameDatabaseRepository gameDatabaseRepository})
      : _gameDatabaseRepository = gameDatabaseRepository,
        super(const LibraryInitial()) {
    on<LibraryGamesUpdated>(_onLibraryGamesUpdated);
    on<LibrarySortingChanged>(_onLibrarySortingChanged);

    _gameDatabaseRepository.all.takeUntil(destroy$).listen((event) {
      add(LibraryGamesUpdated(games: event));
    });
  }

  final PublishSubject<bool> destroy$ = PublishSubject<bool>();
  final GameDatabaseRepository _gameDatabaseRepository;

  _onLibraryGamesUpdated(
    LibraryGamesUpdated event,
    Emitter<LibraryState> emit,
  ) {
    if (state is LibraryLoaded) {
      return emit((state as LibraryLoaded).copyWith(games: event.games));
    } else {
      emit(LibraryLoaded(sorting: state.sorting, games: event.games));
    }
  }

  _onLibrarySortingChanged(
    LibrarySortingChanged event,
    Emitter<LibraryState> emit,
  ) {
    emit(state.copyWith(sorting: event.sorting));
    _gameDatabaseRepository.filter(sorting: event.sorting);
  }

  @override
  Future<void> close() {
    destroy$.add(true);
    return super.close();
  }
}
