import 'package:database_repository/database_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_launcher/src/game/details/configuration_tab/bloc/configuration_tab_bloc.dart';

class SaveProfileWidget extends StatelessWidget {
  final SaveProfileModel saveProfile;
  final String gameVersion;
  final double size;
  const SaveProfileWidget({
    super.key,
    required this.saveProfile,
    required this.gameVersion,
    this.size = 150.0,
  });

  @override
  Widget build(BuildContext context) {
    bool sameVersion = gameVersion == saveProfile.gameVersion;
    return SizedBox.square(
      dimension: size,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                saveProfile.name,
                style: saveProfile.active
                    ? Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Theme.of(context).colorScheme.primary)
                    : Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                saveProfile.gameVersion,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: sameVersion ? null : Colors.red,
                    ),
              ),
              Expanded(child: Container()),
              ElevatedButton(
                onPressed: saveProfile.active
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
                              context
                                  .read<ConfigurationTabBloc>()
                                  .add(ConfigurationTabSwitchSaveProfile(
                                    newSaveProfile: saveProfile,
                                  ));
                            }
                          });
                        } else {
                          context
                              .read<ConfigurationTabBloc>()
                              .add(ConfigurationTabSwitchSaveProfile(
                                newSaveProfile: saveProfile,
                              ));
                        }
                      },
                child: const Text("Activate"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
