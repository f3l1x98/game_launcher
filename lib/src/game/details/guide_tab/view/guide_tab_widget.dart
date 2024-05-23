import 'dart:io';

import 'package:database_repository/database_repository.dart';
import 'package:files_repository/files_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_launcher/src/game/details/guide_tab/cubit/guide_tab_cubit.dart';
import 'package:game_launcher/src/shared/markdown_editor/view/markdown_editor.dart';
import 'package:path/path.dart' as p;

class GuideTabWidget extends StatelessWidget {
  final GameModel game;

  const GuideTabWidget({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GuideTabCubit(
        game: game,
        gameDatabaseRepository: context.read<GameDatabaseRepository>(),
      ),
      child: const _GuideTabWidgetContent(),
    );
  }
}

class _GuideTabWidgetContent extends StatelessWidget {
  const _GuideTabWidgetContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GuideTabCubit, GuideTabState>(
      builder: (context, state) {
        if (state.game.hasGuide) {
          File guideFile = context.read<FilesRepository>().getFile(p.join(
                state.game.metadataPath,
                FilesRepository.gameGuideFileName,
              ));
          if (!guideFile.existsSync()) {
            return _buildCreateGuide(context);
          }
          return MarkdownEditor(
            markdownFile: guideFile,
            editMode: state.editMode,
          );
        } else {
          // Game has no guide -> ask whether user wants to create one
          return _buildCreateGuide(context);
        }
      },
    );
  }

  Widget _buildCreateGuide(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "No guide found!",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 5.0),
        const Text("Do you want to create one?"),
        const SizedBox(height: 5.0),
        ElevatedButton(
          onPressed: () {
            context.read<GuideTabCubit>().updateGameHasGuide();
          },
          child: const Text("Yes"),
        ),
      ],
    );
  }
}
