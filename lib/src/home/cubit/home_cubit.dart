import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:progress_repository/progress_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required ProgressRepository progressRepository})
      : _progressRepository = progressRepository,
        super(const HomeState(currentProgresses: [])) {
    // TODO unsubscribe (I think that is not necessary here, because this will run as long as the app runs)
    _progressRepository.progresses
        .listen((event) => updateCurrentProgresses(event));
  }

  final ProgressRepository _progressRepository;

  updateCurrentProgresses(List<Progress> currentProgresses) {
    emit(state.copyWith(
      currentProgresses: currentProgresses,
    ));
  }
}
