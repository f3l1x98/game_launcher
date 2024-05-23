import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'section_state.dart';

class SectionCubit extends Cubit<SectionState> {
  SectionCubit()
      : super(const SectionState(
          prevButtonEnabled: false,
          nextButtonEnabled: false,
        ));

  setPrevButtonEnabled(bool enabled) {
    emit(state.copyWith(prevButtonEnabled: enabled));
  }

  setNextButtonEnabled(bool enabled) {
    emit(state.copyWith(nextButtonEnabled: enabled));
  }
}
