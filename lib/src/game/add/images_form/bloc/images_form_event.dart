part of 'images_form_bloc.dart';

sealed class ImagesFormEvent extends Equatable {
  const ImagesFormEvent();

  @override
  List<Object> get props => [];
}

final class FormSubmitted extends ImagesFormEvent {}

final class SelectFromDirectory extends ImagesFormEvent {}

final class CoverChanged extends ImagesFormEvent {
  const CoverChanged({required this.cover});

  final String cover;

  @override
  List<Object> get props => [cover];
}

final class ImagesChanged extends ImagesFormEvent {
  const ImagesChanged({required this.images});

  final List<String> images;

  @override
  List<Object> get props => [images];
}
