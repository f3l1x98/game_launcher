import 'package:bloc/bloc.dart';
import 'package:database_repository/database_repository.dart';
import 'package:equatable/equatable.dart';

part 'guide_tab_state.dart';

class GuideTabCubit extends Cubit<GuideTabState> {
  GuideTabCubit({
    required GameModel game,
    required GameDatabaseRepository gameDatabaseRepository,
  })  : _gameDatabaseRepository = gameDatabaseRepository,
        super(GuideTabState(
          editMode: false,
          game: game,
        ));

  final GameDatabaseRepository _gameDatabaseRepository;

  updateGameHasGuide() {
    _gameDatabaseRepository.update(state.game.copyWith(hasGuide: true));
    emit(state.copyWith(editMode: true));
  }
}
