part of 'images_form_bloc.dart';

final class ImagesFormState extends Equatable {
  const ImagesFormState({
    this.status = FormzSubmissionStatus.initial,
    this.cover = const Cover.pure(),
    this.images = const Images.pure(),
    this.isValid = false,
  });

  final FormzSubmissionStatus status;
  final Cover cover;
  final Images images;
  final bool isValid;

  ImagesFormState copyWith({
    FormzSubmissionStatus? status,
    Cover? cover,
    Images? images,
    bool? isValid,
  }) {
    return ImagesFormState(
      status: status ?? this.status,
      cover: cover ?? this.cover,
      images: images ?? this.images,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object> get props => [
        status,
        cover,
        images,
        isValid,
      ];
}
