part of 'configuration_tab_bloc.dart';

sealed class ConfigurationTabState extends Equatable {
  const ConfigurationTabState();

  @override
  List<Object> get props => [];
}

final class ConfigurationTabInitial extends ConfigurationTabState {
  const ConfigurationTabInitial();
}

final class ConfigurationTabLoaded extends ConfigurationTabState {
  const ConfigurationTabLoaded({
    required this.saveProfiles,
    required this.launcherSettings,
  });

  final List<SaveProfileModel> saveProfiles;
  final LauncherSettings launcherSettings;

  ConfigurationTabLoaded copyWith({
    List<SaveProfileModel>? saveProfiles,
    LauncherSettings? launcherSettings,
  }) {
    return ConfigurationTabLoaded(
      saveProfiles: saveProfiles ?? this.saveProfiles,
      launcherSettings: launcherSettings ?? this.launcherSettings,
    );
  }

  @override
  List<Object> get props => [
        ...super.props,
        saveProfiles,
        launcherSettings,
      ];
}
