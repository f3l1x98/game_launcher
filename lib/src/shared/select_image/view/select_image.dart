import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_launcher/src/shared/select_image/cubit/select_image_cubit.dart';
import 'package:game_launcher/src/shared/view/conditional_parent_widget.dart';
import 'package:path/path.dart' as p;

// TODO this shares a lot of code with select_file (with additional preview and multiselect) -> merge
class SelectImage extends StatelessWidget {
  const SelectImage({
    super.key,
    this.initialValue,
    this.allowedExtensions,
    this.decoration,
    this.onChanged,
  }) : _multiSelection = false;
  const SelectImage.multiSelection({
    super.key,
    this.initialValue,
    this.allowedExtensions,
    this.decoration,
    this.onChanged,
  }) : _multiSelection = true;

  final bool _multiSelection;
  final List<String>? initialValue;
  final List<String>? allowedExtensions;
  final InputDecoration? decoration;
  final void Function(List<String> filePaths)? onChanged;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SelectImageCubit(
        multiSelection: _multiSelection,
        initialValue: initialValue,
        onChanged: onChanged,
      ),
      child: _SelectImageContent(
        allowedExtensions: allowedExtensions,
        decoration: decoration,
      ),
    );
  }
}

class _SelectImageContent extends StatelessWidget {
  const _SelectImageContent({
    super.key,
    required this.allowedExtensions,
    required this.decoration,
  });

  final List<String>? allowedExtensions;
  final InputDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return ConditionalParentWidget(
      condition: decoration != null,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Select or File drop target
          Expanded(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  // TODO perhaps move logic into cubit (after all does not need context)
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(
                    allowedExtensions: allowedExtensions,
                    type: FileType.image,
                  )
                      .catchError(
                    (winError) {
                      debugPrint("FilePicker error $winError");
                      return null;
                    },
                  );
                  if (result != null && context.mounted) {
                    context.read<SelectImageCubit>().updateFiles(
                        result.files.map((file) => file.path!).toList());
                  }
                },
                child: DropTarget(
                  onDragDone: (detail) {
                    String selectedPath = detail.files.first.path;
                    // Remove leading . (due to FilePicker vs path libs)
                    if (allowedExtensions == null ||
                        allowedExtensions!
                            .contains(p.extension(selectedPath).substring(1))) {
                      context.read<SelectImageCubit>().addFile(selectedPath);
                    }
                  },
                  child: DottedBorder(
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.5),
                    dashPattern: const [8, 4],
                    padding: const EdgeInsets.all(5.0),
                    child: Center(
                      child: BlocBuilder<SelectImageCubit, SelectImageState>(
                        buildWhen: (previous, current) =>
                            previous.filePaths != current.filePaths,
                        builder: (context, state) {
                          if (state.filePaths.isEmpty) {
                            return const Text(
                                "Drop file here or click to open!");
                          } else {
                            return const _SelectImagePreview();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (allowedExtensions != null)
            Text(
              "Supported file types: ${allowedExtensions!.join(', ')}",
              style: Theme.of(context).textTheme.labelMedium,
            ),
        ],
      ),
      conditionalBuilder: (child) => InputDecorator(
        decoration: decoration!,
        child: child,
      ),
    );
  }
}

class _SelectImagePreview extends StatelessWidget {
  const _SelectImagePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectImageCubit, SelectImageState>(
      buildWhen: (previous, current) => previous.filePaths != current.filePaths,
      builder: (context, state) {
        final multiSelection =
            context.read<SelectImageCubit>().isMultiSelection;
        if (multiSelection) {
          return GridView.builder(
            itemCount: state.filePaths.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2.0,
              mainAxisSpacing: 2.0,
            ),
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38),
                      ),
                      child: Image.file(
                        File(state.filePaths[index]),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0.0,
                    right: 0.0,
                    child: IconButton(
                      onPressed: () {
                        context
                            .read<SelectImageCubit>()
                            .removeFile(state.filePaths[index]);
                      },
                      splashRadius: 20.0,
                      icon: const Icon(Icons.close),
                    ),
                  )
                ],
              );
            },
          );
        } else {
          return Center(
            child: Image.file(
              File(state.filePaths[0]),
            ),
          );
        }
      },
    );
  }
}
