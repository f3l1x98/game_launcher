part of 'image_picker_cubit.dart';

final class ImagePickerState extends Equatable {
  const ImagePickerState({required this.selectedImagePaths});

  final List<String> selectedImagePaths;

  ImagePickerState copyWith({
    List<String>? selectedImagePaths,
  }) {
    return ImagePickerState(
      selectedImagePaths: selectedImagePaths ?? this.selectedImagePaths,
    );
  }

  @override
  List<Object> get props => [selectedImagePaths];
}
