import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'select_archive_state.dart';

class SelectArchiveCubit extends Cubit<SelectArchiveState> {
  SelectArchiveCubit() : super(SelectArchiveState());

  updateFilePath(String? newFilePath) {
    emit(state.copyWith(filePath: newFilePath));
  }
}
