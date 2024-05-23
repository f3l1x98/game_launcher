import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'image_preview_state.dart';

class ImagePreviewCubit extends Cubit<ImagePreviewState> {
  ImagePreviewCubit({required int initialIndex, required List<File> images})
      : super(ImagePreviewState(index: initialIndex, images: images));

  void incrementIndex() {
    _changeIndex(state.index + 1);
  }

  void decrementIndex() {
    _changeIndex(state.index - 1);
  }

  void _changeIndex(int newIndex) {
    if (newIndex < state.images.length) {
      emit(state.copyWith(index: newIndex));
    }
  }
}
