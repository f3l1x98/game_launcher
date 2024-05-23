import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:game_launcher/src/shared/exceptions/unhandled_state_exception.dart';
import 'package:game_launcher/src/shared/markdown_editor/cubit/markdown_editor_cubit.dart';

class MarkdownEditor extends StatelessWidget {
  final File markdownFile;
  final bool editMode;
  final bool showScaffoldMessage;
  final InputDecoration decoration;
  final double? height;
  final bool displayToolbar;
  final Widget Function()? customToolbarBuilder;
  final Function()? onSaved;

  const MarkdownEditor({
    super.key,
    required this.markdownFile,
    this.editMode = false,
    this.showScaffoldMessage = true,
    this.decoration = const InputDecoration(),
    this.height,
    this.displayToolbar = true,
    this.customToolbarBuilder,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MarkdownEditorCubit(
        file: markdownFile,
        isEditMode: editMode,
        showScaffoldMessage: showScaffoldMessage,
        onSaved: onSaved,
      ),
      child: _MarkdownEditorContent(
        showScaffoldMessage: showScaffoldMessage,
        decoration: decoration,
        height: height,
        displayToolbar: displayToolbar,
        customToolbarBuilder: customToolbarBuilder,
      ),
    );
  }
}

class _MarkdownEditorContent extends StatelessWidget {
  final TextEditingController _editController = TextEditingController();
  final FocusNode _editFocusNode = FocusNode();

  final bool showScaffoldMessage;
  final InputDecoration decoration;
  final double? height;
  final bool displayToolbar;
  final Widget Function()? customToolbarBuilder;

  _MarkdownEditorContent({
    super.key,
    required this.showScaffoldMessage,
    required this.decoration,
    required this.height,
    required this.displayToolbar,
    required this.customToolbarBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 100.0,
      child: BlocBuilder<MarkdownEditorCubit, MarkdownEditorState>(
        builder: (context, state) {
          if (state is MarkdownEditorInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is MarkdownEditorFileLoaded) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Markdown(data: state.text),
                ),
                Positioned(
                  right: 0.0,
                  bottom: 0.0,
                  child: IconButton(
                    onPressed: () =>
                        context.read<MarkdownEditorCubit>().setEditMode(true),
                    icon: const Icon(Icons.edit),
                  ),
                ),
              ],
            );
          } else if (state is MarkdownEditorEditing) {
            return CallbackShortcuts(
              bindings: <ShortcutActivator, VoidCallback>{
                const SingleActivator(LogicalKeyboardKey.keyS, control: true):
                    () =>
                        context.read<MarkdownEditorCubit>().saveToFile(context),
                const SingleActivator(LogicalKeyboardKey.keyB, control: true):
                    () => _insertFormat(context, Format.bold),
                const SingleActivator(LogicalKeyboardKey.keyI, control: true):
                    () => _insertFormat(context, Format.italic),
              },
              child: Column(
                children: [
                  if (customToolbarBuilder != null || displayToolbar)
                    customToolbarBuilder != null
                        ? customToolbarBuilder!()
                        : _defaultToolbar(context),
                  Expanded(
                    child:
                        BlocListener<MarkdownEditorCubit, MarkdownEditorState>(
                      // - current is always MarkdownEditorEditing (otherwise this will not be displayed)
                      // - previous can be sth else -> execute listener as this is initial call
                      // - editText != _controller.text
                      listenWhen: (previous, current) =>
                          previous.runtimeType != current.runtimeType ||
                          (current as MarkdownEditorEditing).editText !=
                              _editController.text,
                      listener: (context, state) {
                        _editController.text =
                            (state as MarkdownEditorEditing).editText;
                      },
                      child: TextField(
                        decoration: decoration,
                        autofocus: true,
                        focusNode: _editFocusNode,
                        controller: _editController,
                        maxLines: null,
                        onChanged: (value) {
                          // TODO debounce or sth
                          context
                              .read<MarkdownEditorCubit>()
                              .setEditText(value);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            throw UnhandledStateException(state: state.runtimeType);
          }
        },
      ),
    );
  }

  void _insertFormat(BuildContext context, Format format) {
    switch (format) {
      case Format.bold:
        _insertText(context: context, prefix: "**", suffix: "**");
        break;
      case Format.italic:
        _insertText(context: context, prefix: "__", suffix: "__");
        break;
      case Format.strikethrough:
        _insertText(context: context, prefix: "~~", suffix: "~~");
        break;
      case Format.underline:
        _insertText(context: context, prefix: "<u>", suffix: "</u>");
        break;
    }
  }

  void _insertText({
    required BuildContext context,
    required String prefix,
    String? suffix,
  }) {
    final previousCursorPos = _editController.selection.baseOffset;
    String textInside = "";
    if (!_editController.selection.isCollapsed) {
      // Wrap selection
      textInside = _editController.selection.textInside(_editController.text);
    }
    final newEditText =
        "${_editController.selection.textBefore(_editController.text)}$prefix$textInside$suffix${_editController.selection.textAfter(_editController.text)}";
    context.read<MarkdownEditorCubit>().setEditText(newEditText);
    // Request focus and update cursor pos (changing _controller.text resets it causing no cursor to be displayed)
    _editFocusNode.requestFocus();
    _editController.selection = TextSelection.collapsed(
      offset: previousCursorPos + prefix.length,
    );
  }

  Widget _defaultToolbar(BuildContext context) {
    final btnStyle = ElevatedButton.styleFrom(
      elevation: 0.0,
      minimumSize: const Size(40, 40),
      padding: const EdgeInsets.all(5.0),
      backgroundColor: Colors.black.withOpacity(0),
      foregroundColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
    );
    return Row(
      children: [
        ElevatedButton(
          style: btnStyle,
          onPressed: () {
            _insertFormat(context, Format.bold);
          },
          child: const Icon(Icons.format_bold),
        ),
        ElevatedButton(
          style: btnStyle,
          onPressed: () {
            _insertFormat(context, Format.italic);
          },
          child: const Icon(Icons.format_italic),
        ),
        ElevatedButton(
          style: btnStyle,
          onPressed: () {
            _insertFormat(context, Format.underline);
          },
          child: const Icon(Icons.format_underline),
        ),
        ElevatedButton(
          style: btnStyle,
          onPressed: () {
            _insertFormat(context, Format.strikethrough);
          },
          child: const Icon(Icons.strikethrough_s),
        ),
        ElevatedButton(
          style: btnStyle,
          onPressed: () {
            _insertText(context: context, prefix: "`", suffix: "`");
          },
          child: const Icon(Icons.code),
        ),
        ElevatedButton(
          style: btnStyle,
          onPressed: () {
            _insertText(context: context, prefix: "\n- ");
          },
          child: const Icon(Icons.format_list_bulleted),
        ),
        ElevatedButton(
          style: btnStyle,
          onPressed: () {
            _insertText(context: context, prefix: "\n1. ");
          },
          child: const Icon(Icons.format_list_numbered),
        ),
        ElevatedButton(
          style: btnStyle,
          onPressed: () {
            _insertText(context: context, prefix: "[", suffix: "]()");
          },
          child: const Icon(Icons.link),
        ),
        ElevatedButton(
          style: btnStyle,
          onPressed: () {
            _insertText(context: context, prefix: "![", suffix: "]()");
          },
          child: const Icon(Icons.image),
        ),
        Expanded(child: Container()),
        ElevatedButton(
          style: btnStyle,
          onPressed: () => context
              .read<MarkdownEditorCubit>()
              .saveToFile(context, quitEdit: true),
          child: const Icon(Icons.save),
        ),
      ],
    );
  }
}

enum Format {
  bold,
  italic,
  strikethrough,
  underline,
}
