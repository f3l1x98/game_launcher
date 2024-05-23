import 'package:flutter/material.dart';

/*class GameSaveProfileWidget extends StatelessWidget {
  final GameModel game;
  final GameSaveProfileModel gameSaveProfile;
  final double size;
  const GameSaveProfileWidget({
    super.key,
    required this.game,
    required this.gameSaveProfile,
    this.size = 150.0,
  });

  Future<void> _switchProfile(
    BuildContext context,
    GameDatabaseProvider gameDatabaseProvider,
  ) async {
    bool success = await gameDatabaseProvider.switchActiveSaveProfile(
      game: game,
      newActiveProfile: gameSaveProfile,
    );
    if (!success) {
      ErrorUtils.displayError("Failed to switch save profile.");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool sameVersion = game.version == gameSaveProfile.gameVersion;
    return SizedBox.square(
      dimension: size,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                gameSaveProfile.name,
                style: gameSaveProfile.active
                    ? Theme.of(context)
                        .textTheme
                        .headline6
                        ?.copyWith(color: Theme.of(context).colorScheme.primary)
                    : Theme.of(context).textTheme.headline6,
              ),
              Text(
                gameSaveProfile.gameVersion,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: sameVersion ? null : Colors.red,
                    ),
              ),
              Expanded(child: Container()),
              Consumer<GameDatabaseProvider>(
                builder: (context, gameDatabaseProvider, child) {
                  return ElevatedButton(
                    onPressed: gameSaveProfile.active
                        ? null
                        : () async {
                            if (!sameVersion) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Are you sure?"),
                                  content: const Text(
                                    "You are about to activate a saveprofile that was created for a previous version of the game!",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text("Ok"),
                                    ),
                                  ],
                                ),
                              ).then((value) {
                                if (value) {
                                  _switchProfile(context, gameDatabaseProvider);
                                }
                              });
                            } else {
                              _switchProfile(context, gameDatabaseProvider);
                            }
                          },
                    child: const Text("Activate"),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
*/
