import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_launcher/src/shared/select_file/cubit/select_file_cubit.dart';
import 'package:path/path.dart' as p;

class SelectFile extends StatelessWidget {
  final List<String>? supportedExtensions;
  final Function(String? file) onFileSelected;

  const SelectFile({
    super.key,
    this.supportedExtensions,
    required this.onFileSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SelectFileCubit(
        onFileSelected: onFileSelected,
      ),
      child: _SelectWidgetContent(
        supportedExtensions: supportedExtensions,
      ),
    );
  }
}

class _SelectWidgetContent extends StatelessWidget {
  final List<String>? supportedExtensions;

  const _SelectWidgetContent({super.key, required this.supportedExtensions});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Select or File drop target
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () async {
              // TODO perhaps move logic into cubit (after all does not need context)
              FilePickerResult? result = await FilePicker.platform
                  .pickFiles(
                allowedExtensions: supportedExtensions,
                type: FileType.custom,
              )
                  .catchError(
                (winError) {
                  debugPrint("FilePicker error $winError");
                  return null;
                },
              );
              if (result != null && context.mounted) {
                context
                    .read<SelectFileCubit>()
                    .updateFilePath(result.files.first.path);
              }
            },
            child: DropTarget(
              onDragDone: (detail) {
                String selectedPath = detail.files.first.path;
                // Remove leading . (due to FilePicker vs path libs)
                if (supportedExtensions == null ||
                    supportedExtensions!
                        .contains(p.extension(selectedPath).substring(1))) {
                  context.read<SelectFileCubit>().updateFilePath(selectedPath);
                }
              },
              child: DottedBorder(
                color:
                    Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                dashPattern: const [8, 4],
                padding: const EdgeInsets.all(5.0),
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: Center(
                    child: BlocBuilder<SelectFileCubit, SelectFileState>(
                      buildWhen: (previous, current) =>
                          previous.filePath != current.filePath,
                      builder: (context, state) {
                        if (state.filePath == null) {
                          return const Text("Drop file here or click to open!");
                        } else {
                          return Text(state.filePath!);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (supportedExtensions != null)
          Text(
            "Supported file types: ${supportedExtensions!.join(', ')}",
            style: Theme.of(context).textTheme.labelMedium,
          ),
      ],
    );
  }
}
