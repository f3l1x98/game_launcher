import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'select_image_state.dart';

class SelectImageCubit extends Cubit<SelectImageState> {
  SelectImageCubit({
    required bool multiSelection,
    List<String>? initialValue,
    required this.onChanged,
  })  : _multiSelection = multiSelection,
        super(SelectImageState(filePaths: initialValue ?? []));

  final bool _multiSelection;
  final void Function(List<String> filePaths)? onChanged;

  bool get isMultiSelection => _multiSelection;

  updateFiles(List<String> filePaths) {
    emit(state.copyWith(filePaths: filePaths));
    if (onChanged != null) onChanged!(filePaths);
  }

  addFile(String filePath) {
    updateFiles([
      ...state.filePaths,
      filePath,
    ]);
  }

  removeFile(String filePath) {
    final filePaths = [...state.filePaths];
    filePaths.remove(filePath);
    updateFiles(filePaths);
  }
}
