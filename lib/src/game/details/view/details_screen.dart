import 'package:database_repository/database_repository.dart';
import 'package:files_repository/files_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:game_launcher/src/game/details/bloc/details_bloc.dart';
import 'package:game_launcher/src/game/details/configuration_tab/view/configuration_tab_widget.dart';
import 'package:game_launcher/src/game/details/cubit/installation_cubit.dart';
import 'package:game_launcher/src/game/details/delete_dialog/view/delete_dialog.dart';
import 'package:game_launcher/src/game/details/view/developers_list_widget.dart';
import 'package:game_launcher/src/game/details/guide_tab/view/guide_tab_widget.dart';
import 'package:game_launcher/src/game/details/images_tab/view/images_tab_widget.dart';
import 'package:game_launcher/src/game/details/information_tab/view/information_tab_widget.dart';
import 'package:game_launcher/src/shared/exceptions/unhandled_state_exception.dart';
import 'package:game_launcher/src/shared/view/confirmation_dialog.dart';
import 'package:game_launcher/src/shared/view/content_card.dart';
import 'package:game_launcher/src/shared/view/styled_rating_widget.dart';
import 'package:go_router/go_router.dart';
import 'package:progress_repository/progress_repository.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO SPLIT INTO MULTIPLE FILES (extract subwidgets)

class DetailsScreen extends StatelessWidget {
  final int gameId;

  const DetailsScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DetailsBloc(
        gameId: gameId,
        gameDatabaseRepository: context.read<GameDatabaseRepository>(),
        genreDatabaseRepository: context.read<GenreDatabaseRepository>(),
        developerDatabaseRepository:
            context.read<DeveloperDatabaseRepository>(),
        gameEngineRepository: context.read<GameEngineRepository>(),
        filesRepository: context.read<FilesRepository>(),
      ),
      child: const _DetailsScreenContent(),
    );
  }
}

class _DetailsScreenContent extends StatelessWidget {
  const _DetailsScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentCard(
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 148.0,
        child: Stack(
          children: [
            Positioned.fill(
              child: BlocBuilder<DetailsBloc, DetailsState>(
                buildWhen: (previous, current) =>
                    previous.runtimeType != current.runtimeType,
                builder: (context, state) {
                  if (state is DetailsInitial) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is DetailsLoaded) {
                    return BlocProvider(
                      create: (context) => InstallationCubit(
                        game: state.game,
                        gameDatabaseRepository:
                            context.read<GameDatabaseRepository>(),
                        saveProfileDatabaseRepository:
                            context.read<SaveProfileDatabaseRepository>(),
                        progressRepository: context.read<ProgressRepository>(),
                        filesRepository: context.read<FilesRepository>(),
                        archivesRepository: context.read<ArchivesRepository>(),
                      ),
                      child: _DetailsScreenLoaded(detailsState: state),
                    );
                  } else if (state is DetailsNoGame) {
                    return const Center(
                      child: Text("Game not found."),
                    );
                  } else if (state is DetailsFailure) {
                    // TODO
                    return Center(
                      child: Text(state.message),
                    );
                  } else {
                    throw UnhandledStateException(state: state.runtimeType);
                  }
                },
              ),
            ),
            Positioned(
              top: 0.0,
              left: 0.0,
              child: _buildHeader(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            splashRadius: 20.0,
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        const SizedBox(width: 10.0),
        // TODO this should probably be moved into the _GameDetailsHeader
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                // TODO adjust colors such that text is visible no matter the image below
                Colors.black,
                Colors.black12,
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          constraints: const BoxConstraints(
            maxWidth: 800.0,
          ),
          child: BlocBuilder<DetailsBloc, DetailsState>(
            builder: (context, state) {
              if (state is DetailsLoaded) {
                return Tooltip(
                  message: state.game.name,
                  child: Text(
                    state.game.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              } else if (state is DetailsFailure || state is DetailsInitial) {
                return Container();
              } else {
                throw UnhandledStateException(state: state.runtimeType);
              }
            },
          ),
        ),
      ],
    );
  }
}

class _DetailsScreenLoaded extends StatelessWidget {
  const _DetailsScreenLoaded({super.key, required this.detailsState});

  final DetailsLoaded detailsState;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header containing Image and name
        Expanded(
          flex: 1,
          child: _GameDetailsHeader(
            detailsState: detailsState,
          ),
        ),
        const SizedBox(height: 5.0),
        // Play Button, PopUpMenu and language etc tags
        Container(
          height: 42.0,
          // TODO adjust color etc
          decoration: BoxDecoration(
            color: Colors.black26,
            border: Border.symmetric(
              horizontal: BorderSide(
                color: Theme.of(context).colorScheme.onBackground,
                width: 0.1,
              ),
            ),
          ),
          child: _GameDetailsBar(
            detailsState: detailsState,
          ),
        ),
        // Content
        Expanded(
          flex: 2,
          child: _GameDetailsTabs(
            detailsState: detailsState,
          ),
        ),
      ],
    );
  }
}

class _GameDetailsHeader extends StatelessWidget {
  const _GameDetailsHeader({super.key, required this.detailsState});

  final DetailsLoaded detailsState;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: detailsState.game.coverPath != null
              ? Image.file(
                  context
                      .read<FilesRepository>()
                      .getFile(detailsState.game.coverPath ?? ""),
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    "assets/images/image_not_found.jpg",
                    filterQuality: FilterQuality.high,
                  ),
                  filterQuality: FilterQuality.high,
                )
              : Image.asset(
                  "assets/images/image_not_found.jpg",
                  filterQuality: FilterQuality.high,
                ),
        ),
        Positioned(
          bottom: 0.0,
          left: 0.0,
          child: RatingBar(
            initialRating: detailsState.game.voting.toDouble(),
            itemSize: 30.0,
            ratingWidget: StyledRatingWidget(context),
            ignoreGestures: true,
            // Update is disabled -> nothing to do here
            onRatingUpdate: (double value) {},
          ),
        ),
        Positioned(
          bottom: 0.0,
          right: 0.0,
          child: Chip(
            label: Text(detailsState.gameEngine.displayName),
          ),
        ),
      ],
    );
  }
}

class _GameDetailsBar extends StatelessWidget {
  const _GameDetailsBar({super.key, required this.detailsState});

  final DetailsLoaded detailsState;

  static const _popupMenuOptionOpenLocation = "Open folder";
  static const _popupMenuOptionOpenSavesLocation = "Open saves folder";
  static const _popupMenuOptionOpenMetadataLocation = "Open metadata folder";
  static const _popupMenuOptionOpenWebsite = "Open website";
  static const _popupMenuOptionUpdate = "Update from Archive";
  static const _popupMenuOptionEdit = "Edit";
  static const _popupMenuOptionDeinstall = "Deinstall";
  static const _popupMenuOptionDelete = "Delete";
  static const List<String> _popupMenuOptions = [
    _popupMenuOptionOpenLocation,
    _popupMenuOptionOpenSavesLocation,
    _popupMenuOptionOpenMetadataLocation,
    _popupMenuOptionOpenWebsite,
    _popupMenuOptionUpdate,
    _popupMenuOptionEdit,
    _popupMenuOptionDeinstall,
    _popupMenuOptionDelete,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        detailsState.game.installed
            ? BlocBuilder<DetailsBloc, DetailsState>(
                buildWhen: (previous, current) =>
                    previous.runtimeType != current.runtimeType ||
                    (previous as DetailsLoaded).isRunning !=
                        (current as DetailsLoaded).isRunning,
                builder: (context, state) {
                  return ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: Text((state as DetailsLoaded).isRunning
                        ? "Running"
                        : "Play"),
                    onPressed: state.isRunning
                        ? null
                        : () =>
                            context.read<DetailsBloc>().add(DetailsStartGame()),
                  );
                },
              )
            : BlocBuilder<InstallationCubit, InstallationState>(
                buildWhen: (previous, current) =>
                    previous.runtimeType != current.runtimeType,
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state is InstallationRunning
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (context) => const ConfirmationDialog(
                                content: Text(
                                  'Do you wish to istall this game?',
                                ),
                              ),
                            ).then((value) {
                              // == true because value is bool?
                              if (value == true) {
                                context.read<InstallationCubit>().install();
                              }
                            });
                          },
                    child: const Text("Install"),
                  );
                },
              ),
        BlocBuilder<InstallationCubit, InstallationState>(
          builder: (context, state) {
            return PopupMenuButton(
              splashRadius: 20.0,
              onSelected: (selection) => _handlePopupMenuSelection(
                context,
                selection,
                detailsState,
              ),
              itemBuilder: (context) {
                return _popupMenuOptions
                    .map((option) => PopupMenuItem<String>(
                          enabled: _isPopupItemEnabled(
                            option,
                            state,
                          ),
                          value: option,
                          child: Text(option),
                        ))
                    .toList();
              },
            );
          },
        ),
        const SizedBox(width: 5.0),
        // Version
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Version",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(
              detailsState.game.version,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(width: 10.0),
        // Language
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Language",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Text(
              detailsState.game.language.displayName,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(width: 10.0),
        // devs
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Developer(s)",
              style: Theme.of(context).textTheme.labelLarge,
            ),
            DevelopersListWidget(
              developers: detailsState.developers,
            )
          ],
        ),
      ],
    );
  }

  bool _isPopupItemEnabled(String item, InstallationState installationState) {
    switch (item) {
      case _popupMenuOptionOpenWebsite:
        return detailsState.game.website != null;
      case _popupMenuOptionDeinstall:
      case _popupMenuOptionUpdate:
        return detailsState.game.installed &&
            installationState is! InstallationRunning;
      case _popupMenuOptionDelete:
        return !detailsState.game.installed;
      default:
        return true;
    }
  }

  void _handlePopupMenuSelection(
    BuildContext context,
    String selection,
    DetailsLoaded state,
  ) {
    switch (selection) {
      case _popupMenuOptionOpenLocation:
        launchUrl(Uri.file(
          context.read<FilesRepository>().getFile(state.game.path).path,
        )).catchError((e) {
          // TODO ErrorUtils.displayError(e.message);
          return false;
        });
        break;
      case _popupMenuOptionOpenSavesLocation:
        if (state.game.savesPath != null) {
          launchUrl(Uri.file(
            context.read<FilesRepository>().getFile(state.game.savesPath!).path,
          )).catchError((e) {
            // TODO ErrorUtils.displayError(e.message);
            return false;
          });
        }
        // TODO else display info
        break;
      case _popupMenuOptionOpenMetadataLocation:
        launchUrl(Uri.file(
          context.read<FilesRepository>().getFile(state.game.metadataPath).path,
        )).catchError((e) {
          // TODO ErrorUtils.displayError(e.message);
          return false;
        });
        break;
      case _popupMenuOptionOpenWebsite:
        if (state.game.website != null) {
          launchUrl(Uri.parse(state.game.website!)).catchError((e) {
            // TODO ErrorUtils.displayError(e.message);
            return false;
          });
        }
        break;
      case _popupMenuOptionUpdate:
        // TODO this needs a file picker
        //context.read<InstallationCubit>().update();
        break;
      case _popupMenuOptionEdit:
        context.go("/games/${state.game.id}/edit");
        break;
      case _popupMenuOptionDeinstall:
        showDialog(
          context: context,
          builder: (context) => const ConfirmationDialog(
            content: Text('Do you wish to unistall this game?'),
          ),
        ).then((value) {
          // == true because value is bool?
          if (value == true) {
            context.read<InstallationCubit>().uninstall();
          }
        });
        break;
      case _popupMenuOptionDelete:
        showDialog(
          context: context,
          builder: (context) => GameDeleteDialog(game: state.game),
        );
        break;
      default:
        throw Exception("Unknown popup menu option");
    }
  }
}

class _GameDetailsTabs extends StatelessWidget {
  const _GameDetailsTabs({super.key, required this.detailsState});

  final DetailsLoaded detailsState;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            isScrollable: true,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              const Tab(
                text: "Information",
                height: 30.0,
              ),
              Tab(
                text: "Images (${detailsState.game.images.length})",
                height: 30.0,
              ),
              const Tab(
                text: "Configuration",
                height: 30.0,
              ),
              const Tab(
                text: "Guide",
                height: 30.0,
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Expanded(
            child: TabBarView(
              children: [
                InformationTabWidget(
                  game: detailsState.game,
                  genres: detailsState.genres,
                  developers: detailsState.developers,
                ),
                ImagesTabWidget(game: detailsState.game),
                ConfigurationTabWidget(
                  game: detailsState.game,
                  gameEngine: detailsState.gameEngine,
                ),
                GuideTabWidget(game: detailsState.game),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
