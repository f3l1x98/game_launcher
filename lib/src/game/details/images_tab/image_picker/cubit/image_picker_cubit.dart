import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'image_picker_state.dart';

class ImagePickerCubit extends Cubit<ImagePickerState> {
  ImagePickerCubit({required List<String> initialImages})
      : super(ImagePickerState(selectedImagePaths: initialImages));

  setSelectedImagePaths(List<String> newImagePaths) {
    emit(state.copyWith(selectedImagePaths: newImagePaths));
  }
}
