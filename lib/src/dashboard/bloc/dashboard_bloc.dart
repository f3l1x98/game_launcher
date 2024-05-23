import 'package:bloc/bloc.dart';
import 'package:database_repository/database_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({required GameDatabaseRepository gameDatabaseRepository})
      : _gameDatabaseRepository = gameDatabaseRepository,
        super(const DashboardInitial()) {
    on<DashboardLatestPlayedGamesUpdated>(_onDashboardLatestPlayedGamesUpdated);

    _gameDatabaseRepository.latestPlayedGames
        .takeUntil(destroy$)
        .listen((event) {
      add(DashboardLatestPlayedGamesUpdated(latestPlayedGames: event));
    });
  }

  final PublishSubject<bool> destroy$ = PublishSubject<bool>();
  final GameDatabaseRepository _gameDatabaseRepository;

  _onDashboardLatestPlayedGamesUpdated(
    DashboardLatestPlayedGamesUpdated event,
    Emitter<DashboardState> emit,
  ) {
    if (state is DashboardLoaded) {
      return emit((state as DashboardLoaded)
          .copyWith(latestPlayedGames: event.latestPlayedGames));
    } else {
      emit(DashboardLoaded(latestPlayedGames: event.latestPlayedGames));
    }
  }

  @override
  Future<void> close() {
    destroy$.add(true);
    return super.close();
  }
}
