import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'markdown_editor_state.dart';

class MarkdownEditorCubit extends Cubit<MarkdownEditorState> {
  MarkdownEditorCubit({
    required bool isEditMode,
    required File file,
    required this.showScaffoldMessage,
    this.onSaved,
  }) : super(MarkdownEditorInitial(
          isEditMode: isEditMode,
          file: file,
        )) {
    file.readAsString().then((value) {
      if (!isClosed) {
        emit(MarkdownEditorFileLoaded(
          isEditMode: state.isEditMode,
          file: state.file,
          text: value,
        ));
      }
    });
  }

  final bool showScaffoldMessage;
  final Function()? onSaved;

  setEditMode(bool newValue) {
    emit(state.copyWith(isEditMode: newValue));
  }

  setEditText(String newValue) {
    if (state is MarkdownEditorEditing) {
      emit((state as MarkdownEditorEditing).copyWith(editText: newValue));
    }
  }

  void saveToFile(BuildContext context, {bool quitEdit = false}) {
    if (state is MarkdownEditorEditing) {
      final castState = state as MarkdownEditorEditing;
      if (castState.editText != castState.text) {
        try {
          state.file.writeAsStringSync(
            castState.editText,
            flush: true,
            mode: FileMode.writeOnly,
          );
        } on FileSystemException catch (e) {
          // TODO ErrorUtils.displayError(e.message);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).colorScheme.background,
              content: Text(
                "Error - failed to save file",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          );
          return;
        }
        emit(castState.copyWith(text: castState.editText));
        if (onSaved != null) {
          onSaved!();
        }
        if (showScaffoldMessage) {
          // TODO ScaffoldMessenger should be accessed via BlocListener -> HOW?!?!?
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).colorScheme.background,
              content: Text(
                "File saved!",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
          );
        }
      }
      if (quitEdit) {
        emit(MarkdownEditorFileLoaded(
          isEditMode: castState.isEditMode,
          file: castState.file,
          text: castState.text,
        ));
      }
    }
  }
}
