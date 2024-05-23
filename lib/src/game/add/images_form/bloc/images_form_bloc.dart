import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:database_repository/database_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:formz/formz.dart';
import 'package:game_launcher/src/game/add/images_form/models/cover.dart';
import 'package:game_launcher/src/game/add/images_form/models/images.dart';
import 'package:path/path.dart' as p;

part 'images_form_event.dart';
part 'images_form_state.dart';

// TODO perhaps move into somekind of global_constants.dart
const List<String> supportedImageExtensions = ["png", "jpg", "jpeg", "gif"];

class ImagesFormBloc extends Bloc<ImagesFormEvent, ImagesFormState> {
  ImagesFormBloc({required GameDatabaseRepository gameDatabaseRepository})
      : _gameDatabaseRepository = gameDatabaseRepository,
        super(const ImagesFormState()) {
    on<CoverChanged>(_onCoverChanged);
    on<ImagesChanged>(_onImagesChanged);
    on<SelectFromDirectory>(_onSelectFromDirectory);
    on<FormSubmitted>(_onFormSubmitted);
  }

  final GameDatabaseRepository _gameDatabaseRepository;

  _onSelectFromDirectory(
    SelectFromDirectory event,
    Emitter<ImagesFormState> emit,
  ) async {
    try {
      // TODO does not work (at least no UI update)
      var result = await FilePicker.platform.getDirectoryPath();
      if (result != null) {
        var files = await Directory(result)
            .list()
            .where((entry) =>
                entry is File &&
                supportedImageExtensions
                    .contains(p.extension(entry.path).substring(1)))
            .cast<File>()
            .toList();
        var coverFile = files.firstWhereOrNull(_coverFilter);
        var imageFiles = files.whereNot(_coverFilter);
        if (isClosed) return;
        if (coverFile != null) {
          add(CoverChanged(cover: coverFile.absolute.path));
        }
        add(ImagesChanged(
            images: imageFiles.map((e) => e.absolute.path).toList()));
      }
    } on Exception catch (e) {
      // TODO debugPrint(e.toString());
    }
  }

  bool _coverFilter(File element) =>
      p.basenameWithoutExtension(element.path) == 'cover';

  _onCoverChanged(
    CoverChanged event,
    Emitter<ImagesFormState> emit,
  ) {
    final cover = Cover.dirty(event.cover);
    emit(state.copyWith(
      cover: cover,
      isValid: _validateWithState(cover: cover),
    ));
  }

  bool _validateWithState({
    Cover? cover,
    Images? images,
  }) {
    return Formz.validate([
      cover ?? state.cover,
      images ?? state.images,
    ]);
  }

  _onImagesChanged(
    ImagesChanged event,
    Emitter<ImagesFormState> emit,
  ) {
    final images = Images.dirty(event.images);
    emit(state.copyWith(
      images: images,
      isValid: _validateWithState(images: images),
    ));
  }

  _onFormSubmitted(
    FormSubmitted event,
    Emitter<ImagesFormState> emit,
  ) async {
    if (state.isValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));
      try {
        _gameDatabaseRepository.updateImagesForm(
          cover: state.cover.value,
          images: state.images.value,
        );
        emit(state.copyWith(status: FormzSubmissionStatus.success));
      } catch (_) {
        emit(state.copyWith(status: FormzSubmissionStatus.failure));
      }
    }
  }
}
