import 'package:files_repository/files_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_launcher/src/game/library/select_archive_dialog/cubit/select_archive_cubit.dart';
import 'package:game_launcher/src/shared/select_file/view/select_file.dart';

class SelectArchiveDialog extends StatelessWidget {
  const SelectArchiveDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        constraints: const BoxConstraints(
          maxWidth: 800.0,
          maxHeight: 500.0,
        ),
        child: BlocProvider(
          create: (context) => SelectArchiveCubit(),
          child: _SelectArchiveDialogContent(),
        ),
      ),
    );
  }
}

class _SelectArchiveDialogContent extends StatelessWidget {
  const _SelectArchiveDialogContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Select game archive file",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10.0),
        // Select or File drop target
        SelectFile(
          onFileSelected: context.read<SelectArchiveCubit>().updateFilePath,
          supportedExtensions: context
              .read<ArchivesRepository>()
              .supportedArchiveExtensions
              .map((e) => e.substring(1))
              .toList(),
        ),
        const SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            const SizedBox(width: 5.0),
            BlocBuilder<SelectArchiveCubit, SelectArchiveState>(
              buildWhen: (previous, current) =>
                  previous.filePath != current.filePath,
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state.filePath != null
                      ? () => Navigator.of(context).pop(state.filePath)
                      : null,
                  child: const Text("Select"),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
