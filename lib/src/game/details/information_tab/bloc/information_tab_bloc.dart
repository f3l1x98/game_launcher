import 'package:bloc/bloc.dart';
import 'package:database_repository/database_repository.dart';
import 'package:equatable/equatable.dart';

part 'information_tab_event.dart';
part 'information_tab_state.dart';

class InformationTabBloc
    extends Bloc<InformationTabEvent, InformationTabState> {
  InformationTabBloc({
    required int? prequelId,
    required int? sequelId,
    required GameDatabaseRepository gameDatabaseRepository,
  })  : _gameDatabaseRepository = gameDatabaseRepository,
        super(InformationTabInitial()) {
    on<InformationTabLoadedSuccess>(_onInformationTabLoadedSuccess);

    final List<Future<GameModel?>> futures = [];
    if (prequelId != null) {
      futures.add(_gameDatabaseRepository.getById(prequelId));
    }
    if (sequelId != null) {
      futures.add(_gameDatabaseRepository.getById(sequelId));
    }
    Future.wait(futures).then((values) {
      final prequel = prequelId != null ? values[0] : null;
      final sequel = sequelId != null && prequelId != null
          ? values[1]
          : (sequelId != null ? values[0] : null);

      // TODO perhaps add state signaling that one of them could not be retrieved, eg (prequelId != null && prequel == null) || (sequelId != null && sequel == null)
      add(InformationTabLoadedSuccess(prequel: prequel, sequel: sequel));
    });
  }

  final GameDatabaseRepository _gameDatabaseRepository;

  _onInformationTabLoadedSuccess(
    InformationTabLoadedSuccess event,
    Emitter<InformationTabState> emit,
  ) {
    emit(InformationTabLoaded(
      prequel: event.prequel,
      sequel: event.sequel,
    ));
  }
}
