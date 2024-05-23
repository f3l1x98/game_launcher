import 'package:database_repository/database_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_launcher/src/dashboard/bloc/dashboard_bloc.dart';
import 'package:game_launcher/src/dashboard/section/view/section_widget.dart';
import 'package:game_launcher/src/dashboard/view/card_widget.dart';
import 'package:game_launcher/src/shared/exceptions/unhandled_state_exception.dart';
import 'package:game_launcher/src/shared/view/game_card_widget.dart';
import 'package:progress_repository/progress_repository.dart';
import 'package:path/path.dart' as p;

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardBloc>(
      create: (context) => DashboardBloc(
        gameDatabaseRepository: context.read<GameDatabaseRepository>(),
      ),
      child: const _DashboardScreenContent(),
    );
  }
}

class _DashboardScreenContent extends StatelessWidget {
  const _DashboardScreenContent({super.key});

  // TODO PERHAPS STORE IN SETTINGS?!?!?
  static const _saveEditorUrl = "https://www.saveeditonline.com/";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionWidget(
          header: "Tools",
          content: [
            CardWidget(
              icon: Icons.save_as,
              name: "Save editor",
              onTap: () {
                /*showDialog(
                  context: context,
                  builder: (context) => const ExternalLinkAlertDialog(
                    externalLink: _saveEditorUrl,
                  ),
                );*/
                // TODO
              },
            ),
            CardWidget(
              icon: Icons.save_as,
              name: "Test progress",
              onTap: () {
                Progress p = Progress.fromPercentage(
                  percentage: 0,
                  name: "Test progress",
                  description: "Testing...",
                );
                Stream.periodic(
                  const Duration(milliseconds: 100),
                  (count) => count,
                ).listen((event) {
                  if (event < 100) {
                    p = Progress.advanceBase(base: p);
                    context.read<ProgressRepository>().upsertProgress(p);
                  }
                });
              },
            ),
            CardWidget(
              icon: Icons.save_as,
              name: "Test path",
              onTap: () {
                const gameName = "A cloud with little to do";
                final gamePath = "${p.separator}$gameName";
                final gamePath2 = "${p.separator}test${p.separator}$gameName";
                final gameDirectoryName = p.basename(gamePath);
                final gameDirectoryName2 = p.basename(gamePath2);
                print(gameDirectoryName);
                print(gameDirectoryName2);

                const gamePathUnix = "/$gameName";
                final gameDirectoryNameUnix = p.basename(gamePathUnix);
                print(gameDirectoryNameUnix);
                print(
                    "Starts with separator ${gameDirectoryNameUnix.startsWith(p.separator)}");

                print(p.join(p.separator, "Test"));

                // RESULTS:
                // - basename can remove separators of other systems -> can remove unix separator while running in Windows
                // - startsWith(p.separator) only check on the separator of this system -> false for unix separator in case of Windows
              },
            ),
          ],
        ),
        const SizedBox(height: 10.0),
        BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardInitial) {
              return const SectionWidget(
                header: "Last played",
                scrollable: true,
                content: [
                  Center(child: CircularProgressIndicator()),
                ],
              );
            } else if (state is DashboardLoaded) {
              return SectionWidget(
                header: "Last played",
                scrollable: true,
                content: state.latestPlayedGames
                    .map((game) => GameCardWidget(
                          size: const Size(200, 304),
                          game: game,
                        ))
                    .toList(),
              );
            } else {
              throw UnhandledStateException(state: state.runtimeType);
            }
          },
        ),
        const Center(
          child: Text('Dashboard, TODO display last played games'),
        ),
      ],
    );
  }
}
