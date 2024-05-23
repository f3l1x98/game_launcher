import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'select_file_state.dart';

class SelectFileCubit extends Cubit<SelectFileState> {
  SelectFileCubit({
    required Function(String? file) onFileSelected,
  })  : _onFileSelected = onFileSelected,
        super(const SelectFileState());

  final Function(String? file) _onFileSelected;

  updateFilePath(String? newFilePath) {
    emit(state.copyWith(filePath: newFilePath));
    _onFileSelected(newFilePath);
  }
}
