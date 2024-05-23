import 'package:database_repository/database_repository.dart';
import 'package:files_repository/files_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_launcher/src/game/details/configuration_tab/bloc/configuration_tab_bloc.dart';
import 'package:game_launcher/src/game/details/configuration_tab/add_save_profile_dialog/view/add_save_profile_dialog.dart';
import 'package:game_launcher/src/game/details/configuration_tab/view/save_profile_widget.dart';
import 'package:game_launcher/src/shared/exceptions/unhandled_state_exception.dart';
import 'package:settings_repository/settings_repository.dart';

class ConfigurationTabWidget extends StatelessWidget {
  final GameModel game;
  final GameEngineModel gameEngine;

  const ConfigurationTabWidget({
    super.key,
    required this.game,
    required this.gameEngine,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConfigurationTabBloc(
        game: game,
        gameEngine: gameEngine,
        gameDatabaseRepository: context.read<GameDatabaseRepository>(),
        saveProfileDatabaseRepository:
            context.read<SaveProfileDatabaseRepository>(),
        filesRepository: context.read<FilesRepository>(),
        settingsRepository: context.read<SettingsRepository>(),
      ),
      child: _ConfigurationTabContent(game: game),
    );
  }
}

class _ConfigurationTabContent extends StatelessWidget {
  final GameModel game;

  const _ConfigurationTabContent({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          // Disable if no savespath found
          child: game.savesPath != null
              ? BlocBuilder<ConfigurationTabBloc, ConfigurationTabState>(
                  builder: (context, state) {
                    if (state is ConfigurationTabInitial) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (state is ConfigurationTabLoaded) {
                      return SingleChildScrollView(
                        child: Wrap(
                          spacing: 5.0,
                          runSpacing: 5.0,
                          children: [
                            ...state.saveProfiles
                                .map((saveProfile) => SaveProfileWidget(
                                      size: 150.0,
                                      gameVersion: game.version,
                                      saveProfile: saveProfile,
                                    ))
                                .toList(),
                            // TODO at start or end of list?!?!?
                            SizedBox.square(
                              dimension: 150.0,
                              child: Card(
                                child: IconButton(
                                  iconSize: 50.0,
                                  splashRadius: 30.0,
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          AddSaveProfileDialog(
                                        game: game,
                                        saveProfiles: state.saveProfiles,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add_circle),
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
                )
              : const SizedBox(
                  child: Center(
                    child: Text("This game does not use saves."),
                  ),
                ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text("Full save available"),
                    ),
                    Switch(
                      value: game.fullSaveAvailable,
                      // Disable if no savespath found
                      onChanged: game.savesPath != null
                          ? (newValue) => context
                              .read<ConfigurationTabBloc>()
                              .add(ConfigurationTabUpdateFullSave(
                                fullSave: newValue,
                              ))
                          : null,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
