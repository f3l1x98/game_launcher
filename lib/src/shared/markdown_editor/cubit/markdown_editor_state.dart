part of 'markdown_editor_cubit.dart';

sealed class MarkdownEditorState extends Equatable {
  const MarkdownEditorState({
    required this.isEditMode,
    required this.file,
  });

  final bool isEditMode;
  final File file;

  MarkdownEditorState copyWith({
    bool? isEditMode,
    File? file,
  });

  @override
  List<Object> get props => [isEditMode, file];
}

final class MarkdownEditorInitial extends MarkdownEditorState {
  const MarkdownEditorInitial({required super.isEditMode, required super.file});

  @override
  MarkdownEditorState copyWith({
    bool? isEditMode,
    File? file,
  }) {
    return MarkdownEditorInitial(
      isEditMode: isEditMode ?? this.isEditMode,
      file: file ?? this.file,
    );
  }
}

class MarkdownEditorFileLoaded extends MarkdownEditorState {
  const MarkdownEditorFileLoaded({
    required super.isEditMode,
    required super.file,
    required this.text,
  });

  final String text;

  @override
  MarkdownEditorFileLoaded copyWith({
    bool? isEditMode,
    File? file,
    String? text,
  }) {
    return MarkdownEditorFileLoaded(
      isEditMode: isEditMode ?? this.isEditMode,
      file: file ?? this.file,
      text: text ?? this.text,
    );
  }

  @override
  List<Object> get props => [...super.props, text];
}

final class MarkdownEditorEditing extends MarkdownEditorFileLoaded {
  const MarkdownEditorEditing({
    required super.isEditMode,
    required super.file,
    required super.text,
    required this.editText,
  });

  final String editText;

  @override
  MarkdownEditorEditing copyWith({
    bool? isEditMode,
    File? file,
    String? text,
    String? editText,
  }) {
    return MarkdownEditorEditing(
      isEditMode: isEditMode ?? this.isEditMode,
      file: file ?? this.file,
      text: text ?? this.text,
      editText: editText ?? this.editText,
    );
  }

  @override
  List<Object> get props => [...super.props, editText];
}
