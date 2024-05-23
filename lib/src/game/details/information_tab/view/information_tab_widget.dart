import 'package:database_repository/database_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:game_launcher/src/game/details/information_tab/bloc/information_tab_bloc.dart';
import 'package:game_launcher/src/shared/view/genre_badge_widget.dart';
import 'package:go_router/go_router.dart';

class InformationTabWidget extends StatelessWidget {
  final GameModel game;
  final List<GenreModel> genres;
  final List<DeveloperModel> developers;

  const InformationTabWidget({
    super.key,
    required this.game,
    required this.genres,
    required this.developers,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InformationTabBloc(
        gameDatabaseRepository: context.read<GameDatabaseRepository>(),
        prequelId: game.prequelId,
        sequelId: game.sequelId,
      ),
      child: _InformationTabWidgetContent(
        game: game,
        genres: genres,
        developers: developers,
      ),
    );
  }
}

class _InformationTabWidgetContent extends StatelessWidget {
  final GameModel game;
  final List<GenreModel> genres;
  final List<DeveloperModel> developers;

  const _InformationTabWidgetContent({
    super.key,
    required this.game,
    required this.genres,
    required this.developers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 5.0,
          runSpacing: 5.0,
          children: genres
              .map((genre) => GenreBadgeWidget(
                    genre: genre,
                    selected: false,
                    small: true,
                  ))
              .toList(),
        ),
        const SizedBox(height: 5.0),
        if (game.prequelId != null || game.sequelId != null)
          _buildPrequel(context: context),
        if (game.prequelId != null || game.sequelId != null)
          _buildSequel(context: context),
        // TODO edit description: hover over header shows edit btn -> edit inline
        Text(
          "Description",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Expanded(
          child: Markdown(
            data: game.description ?? "",
            padding: const EdgeInsets.all(2.0),
          ),
        ),
      ],
    );
  }

  Widget _buildPrequel({required BuildContext context}) {
    return BlocBuilder<InformationTabBloc, InformationTabState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      builder: (context, state) {
        if (state is InformationTabLoaded) {
          return _buildPrequelSequel(
            context: context,
            label: "Prequel",
            linkedGame: state.prequel,
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _buildSequel({required BuildContext context}) {
    return BlocBuilder<InformationTabBloc, InformationTabState>(
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      builder: (context, state) {
        if (state is InformationTabLoaded) {
          return _buildPrequelSequel(
            context: context,
            label: "Sequel",
            linkedGame: state.sequel,
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _buildPrequelSequel({
    required BuildContext context,
    required GameModel? linkedGame,
    required String label,
  }) {
    // TODO handle if linkedGame == null -> failed to get
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              constraints: const BoxConstraints(minWidth: 100.0),
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 5.0),
            linkedGame != null
                ? MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => context.go("/games/${linkedGame.id}"),
                      child: Text(
                        linkedGame.name,
                      ),
                    ),
                  )
                : const Text("-"),
          ],
        ),
        const SizedBox(height: 5.0),
      ],
    );
  }
}
