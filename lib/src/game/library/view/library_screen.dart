import 'package:database_repository/database_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_launcher/src/game/library/bloc/library_bloc.dart';
import 'package:game_launcher/src/game/library/filter/view/filter_dialog.dart';
import 'package:game_launcher/src/game/library/select_archive_dialog/view/select_archive_dialog.dart';
import 'package:game_launcher/src/game/library/sorting_display_extension.dart';
import 'package:game_launcher/src/shared/exceptions/unhandled_state_exception.dart';
import 'package:game_launcher/src/shared/view/game_card_widget.dart';
import 'package:game_launcher/src/shared/paginated_wrap/view/paginated_wrap_widget.dart';
import 'package:game_launcher/src/shared/view/content_card.dart';
import 'package:go_router/go_router.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LibraryBloc(
        gameDatabaseRepository: context.read<GameDatabaseRepository>(),
      ),
      child: _LibraryScreenContent(),
    );
  }
}

class _LibraryScreenContent extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  _LibraryScreenContent({super.key});

  bool _buildWhenGamesChange(LibraryState previous, LibraryState current) {
    if (previous is LibraryInitial && current is LibraryInitial) {
      return false;
    } else if (previous is LibraryInitial && current is LibraryLoaded) {
      return true;
    } else if (previous is LibraryLoaded && current is LibraryLoaded) {
      return previous.games != current.games;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Row(
          children: [
            BlocBuilder<LibraryBloc, LibraryState>(
              buildWhen: _buildWhenGamesChange,
              builder: (context, state) {
                if (state is LibraryLoaded) {
                  return Badge.count(
                    count: state.games.length,
                    offset: const Offset(10, 5),
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    largeSize: 20.0,
                    textStyle: Theme.of(context).textTheme.bodyMedium,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: Text(
                      "Games",
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  );
                } else {
                  return Text(
                    "Games",
                    style: Theme.of(context).textTheme.displaySmall,
                  );
                }
              },
            ),
            ElevatedButton(
              onPressed: () {
                print("TODO");
                // Dialog for selecting archive of game
                showDialog(
                  context: context,
                  builder: (context) => const SelectArchiveDialog(),
                ).then((value) {
                  if (value != null) {
                    // Open add game page with selected archive
                    context.go('/games/new', extra: {'archivePath': value});
                  }
                });
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all(const CircleBorder()),
                padding: MaterialStateProperty.all(const EdgeInsets.all(8.0)),
              ),
              child: const Icon(Icons.add),
            ),
            const Spacer(),
            // Sorting
            BlocBuilder<LibraryBloc, LibraryState>(
              buildWhen: (previous, current) =>
                  previous.sorting != current.sorting,
              builder: (context, state) {
                return DropdownButton<Sorting>(
                  value: state.sorting,
                  items: Sorting.values
                      .map((sortEnum) => DropdownMenuItem<Sorting>(
                            value: sortEnum,
                            child: Text(
                              sortEnum.getDisplayName(),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      context
                          .read<LibraryBloc>()
                          .add(LibrarySortingChanged(sorting: value));
                    }
                  },
                );
              },
            ),
            // Filter button
            IconButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => const FilterDialog(),
              ),
              icon: const Icon(Icons.filter_list),
            ),
          ],
        ),
        const SizedBox(height: 10.0),
        // Games
        Expanded(
          child: ContentCard(
            child: BlocBuilder<LibraryBloc, LibraryState>(
              builder: (context, state) {
                if (state is LibraryInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is LibraryLoaded) {
                  return SingleChildScrollView(
                    controller: _scrollController,
                    child: PaginatedWrap(
                      //initialPage: gameDatabaseProvider.libraryPage,
                      onPageChanged: (newPageNr) {
                        _scrollController.jumpTo(0.0);
                        //gameDatabaseProvider.libraryPage = newPageNr;
                      },
                      items: state.games
                          .map((game) => GameCardWidget(game: game))
                          .toList(),
                    ),
                  );
                } else {
                  throw UnhandledStateException(state: state.runtimeType);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
