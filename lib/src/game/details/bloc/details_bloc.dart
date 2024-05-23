import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:database_repository/database_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:files_repository/files_repository.dart';
import 'package:settings_repository/settings_repository.dart';
import 'package:shared_kernel/shared_kernel.dart';
import 'package:rxdart/rxdart.dart';

part 'details_event.dart';
part 'details_state.dart';

class DetailsBloc extends Bloc<DetailsEvent, DetailsState> {
  DetailsBloc({
    required int gameId,
    required GameDatabaseRepository gameDatabaseRepository,
    required GenreDatabaseRepository genreDatabaseRepository,
    required DeveloperDatabaseRepository developerDatabaseRepository,
    required GameEngineRepository gameEngineRepository,
    required FilesRepository filesRepository,
  })  : _gameDatabaseRepository = gameDatabaseRepository,
        _genreDatabaseRepository = genreDatabaseRepository,
        _developerDatabaseRepository = developerDatabaseRepository,
        _gameEngineRepository = gameEngineRepository,
        _filesRepository = filesRepository,
        super(DetailsInitial()) {
    // General
    on<DetailsLoadedSuccess>(_onDetailsLoadedSuccess);
    on<DetailsLoadedGameNotFound>(_onDetailsLoadedGameNotFound);
    on<DetailsUpdateGame>(_onDetailsUpdateGame);
    on<DetailsStartGame>(_onDetailsStartGame);
    on<DetailsStopGame>(_onDetailsStopGame);
    on<DetailsGameError>(_onDetailsGameError);

    CombineLatestStream.list([
      _gameDatabaseRepository.getByIdStream(gameId),
      _genreDatabaseRepository.getByGameIdStream(gameId),
      _developerDatabaseRepository.getByGameIdStream(gameId),
    ]).takeUntil(destroy$).listen((values) {
      final game = values[0] as GameModel?;
      final genres = values[1] as List<GenreModel>;
      final developers = values[2] as List<DeveloperModel>;
      if (game != null) {
        add(DetailsLoadedSuccess(
          game: game,
          genres: genres,
          developers: developers,
          gameEngine:
              _gameEngineRepository.getGameEngine(game.usedGameEngineEnum),
        ));
      } else {
        add(const DetailsLoadedGameNotFound());
      }
    });
  }

  final PublishSubject<bool> destroy$ = PublishSubject<bool>();
  final GameDatabaseRepository _gameDatabaseRepository;
  final GenreDatabaseRepository _genreDatabaseRepository;
  final DeveloperDatabaseRepository _developerDatabaseRepository;
  final GameEngineRepository _gameEngineRepository;
  final FilesRepository _filesRepository;

  _onDetailsLoadedSuccess(
    DetailsLoadedSuccess event,
    Emitter<DetailsState> emit,
  ) {
    emit(DetailsLoaded(
      game: event.game,
      genres: event.genres,
      developers: event.developers,
      gameEngine: event.gameEngine,
    ));
  }

  _onDetailsLoadedGameNotFound(
    DetailsLoadedGameNotFound event,
    Emitter<DetailsState> emit,
  ) {
    emit(DetailsNoGame());
  }

  _onDetailsUpdateGame(
    DetailsUpdateGame event,
    Emitter<DetailsState> emit,
  ) async {
    if (state is DetailsLoaded) {
      await _gameDatabaseRepository.update(event.game);
      emit((state as DetailsLoaded).copyWith(game: event.game));
    }
  }

  _onDetailsStartGame(
    DetailsStartGame event,
    Emitter<DetailsState> emit,
  ) async {
    if (state is DetailsLoaded) {
      // TODO start game
      final game = (state as DetailsLoaded).game;

      final exe = _filesRepository.getFile(game.exePath);
      Future<Process?> gameProcessFuture =
          ProgramExecutor.execute(exe.absolute.path);
      final gameProcess = await gameProcessFuture.catchError((error) {
        return null;
      });
      if (gameProcess == null) {
        add(const DetailsGameError(message: "Failed to start game."));
        return;
      }
      // Update lastPlayedAt
      _gameDatabaseRepository.update(game.copyWith(
        lastPlayedAt: DateTime.now(),
      ));

      emit((state as DetailsLoaded).copyWith(isRunning: true));

      // Wait for game process to end
      gameProcess.exitCode.whenComplete(() {
        if (!isClosed) {
          // TODO Assert that the page is still mounted before updating state
          add(DetailsStopGame());
        }
      });
    }
  }

  _onDetailsStopGame(
    DetailsStopGame event,
    Emitter<DetailsState> emit,
  ) {
    if (state is DetailsLoaded) {
      emit((state as DetailsLoaded).copyWith(isRunning: false));
    }
  }

  _onDetailsGameError(
    DetailsGameError event,
    Emitter<DetailsState> emit,
  ) {
    emit(DetailsFailure(message: event.message));
  }

  @override
  Future<void> close() {
    destroy$.add(true);
    return super.close();
  }
}
