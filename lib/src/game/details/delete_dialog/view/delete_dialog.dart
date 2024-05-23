import 'package:database_repository/database_repository.dart';
import 'package:files_repository/files_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_launcher/src/game/details/delete_dialog/cubit/delete_dialog_cubit.dart';

class GameDeleteDialog extends StatelessWidget {
  const GameDeleteDialog({
    super.key,
    required this.game,
  });

  final GameModel game;

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
          create: (context) => DeleteDialogCubit(
            game: game,
            gameDatabaseRepository: context.read<GameDatabaseRepository>(),
            filesRepository: context.read<FilesRepository>(),
          ),
          child: const _DeleteDialogContent(),
        ),
      ),
    );
  }
}

class _DeleteDialogContent extends StatelessWidget {
  const _DeleteDialogContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Do you want to delete the game?"),
        const SizedBox(height: 5.0),
        const _DeleteArchiveInput(),
        const _DeleteMetadataInput(),
        /*FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              FormBuilderCheckbox(
                name: 'archive',
                title: const Text("Delete archive"),
                initialValue: true,
              ),
              FormBuilderCheckbox(
                name: 'metadata',
                title: const Tooltip(
                  message:
                      "Metadata refers to the images as well as the save profiles",
                  child: Text("Delete metadata"),
                ),
                initialValue: true,
              ),
            ],
          ),
        ),*/
        const SizedBox(height: 15.0),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            const SizedBox(width: 10.0),
            ElevatedButton(
              onPressed: () async {
                context.read<DeleteDialogCubit>().deleteGame();
                // TODO old impl had isLoading check to disable btn
                /*if (_formKey.currentState?.validate() ?? false) {
                  final deleteArchive =
                      _formKey.currentState!.fields['archive']!.value;
                  final deleteMetadata =
                      _formKey.currentState!.fields['metadata']!.value;

                  await deleteGame(
                    context: context,
                    deleteArchive: deleteArchive,
                    deleteMetadata: deleteMetadata,
                  );

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }*/
              },
              child: const Text('Yes'),
            )
          ],
        ),
      ],
    );
  }
}

class _DeleteArchiveInput extends StatelessWidget {
  const _DeleteArchiveInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeleteDialogCubit, DeleteDialogState>(
      buildWhen: (previous, current) =>
          previous.deleteArchive != current.deleteArchive,
      builder: (context, state) {
        // TODO
        return CheckboxListTile(
          title: const Text("Delete archive"),
          value: state.deleteArchive.value,
          onChanged: (value) => context
              .read<DeleteDialogCubit>()
              .updateDeleteArchive(newValue: value!),
        );
      },
    );
  }
}

class _DeleteMetadataInput extends StatelessWidget {
  const _DeleteMetadataInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeleteDialogCubit, DeleteDialogState>(
      buildWhen: (previous, current) =>
          previous.deleteArchive != current.deleteArchive,
      builder: (context, state) {
        // TODO
        return CheckboxListTile(
          title: const Tooltip(
            message:
                "Metadata refers to the images as well as the save profiles",
            child: Text("Delete metadata"),
          ),
          value: state.deleteArchive.value,
          onChanged: (value) => context
              .read<DeleteDialogCubit>()
              .updateDeleteArchive(newValue: value!),
        );
      },
    );
  }
}
