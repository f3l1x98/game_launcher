part of 'image_preview_cubit.dart';

final class ImagePreviewState extends Equatable {
  const ImagePreviewState({required this.index, required this.images});

  final int index;
  final List<File> images;

  ImagePreviewState copyWith({
    int? index,
    List<File>? images,
  }) {
    return ImagePreviewState(
      index: index ?? this.index,
      images: images ?? this.images,
    );
  }

  File getCurrentImageFile() {
    return images[index];
  }

  @override
  List<Object> get props => [index, images];
}
