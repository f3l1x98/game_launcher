part of 'configuration_tab_bloc.dart';

sealed class ConfigurationTabEvent extends Equatable {
  const ConfigurationTabEvent();

  @override
  List<Object> get props => [];
}

final class ConfigurationTabLoadedSuccess extends ConfigurationTabEvent {
  const ConfigurationTabLoadedSuccess({
    required this.saveProfiles,
    required this.launcherSettings,
  });

  final List<SaveProfileModel> saveProfiles;
  final LauncherSettings launcherSettings;

  @override
  List<Object> get props => [
        saveProfiles,
        launcherSettings,
      ];
}

final class ConfigurationTabSwitchSaveProfile extends ConfigurationTabEvent {
  const ConfigurationTabSwitchSaveProfile({required this.newSaveProfile});

  final SaveProfileModel newSaveProfile;

  @override
  List<Object> get props => [newSaveProfile];
}

final class ConfigurationTabUpdateFullSave extends ConfigurationTabEvent {
  const ConfigurationTabUpdateFullSave({required this.fullSave});

  final bool fullSave;

  @override
  List<Object> get props => [fullSave];
}
