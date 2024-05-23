import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:progress_repository/progress_repository.dart';
import 'package:rxdart/rxdart.dart';

part 'progress_state.dart';

class ProgressCubit extends Cubit<ProgressState> {
  ProgressCubit({required ProgressRepository progressRepository})
      : _progressRepository = progressRepository,
        super(const ProgressState(currentProgresses: [])) {
    _progressRepository.progresses
        .takeUntil(destroy$)
        .listen((event) => updateCurrentProgresses(event));
  }

  final PublishSubject<bool> destroy$ = PublishSubject<bool>();
  final ProgressRepository _progressRepository;

  updateCurrentProgresses(List<Progress> currentProgresses) {
    emit(state.copyWith(
      currentProgresses: currentProgresses,
    ));
  }

  @override
  Future<void> close() {
    destroy$.add(true);
    return super.close();
  }
}
