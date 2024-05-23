import 'package:settings_repository/settings_repository.dart';

class SettingsRepository extends AbstractSettingsRepository {
  SettingsRepository({required super.settingsClient});

  @override
  Stream<AppSettings> get appSettings => settingsClient.appSettings
      .map((event) => AppSettings.fromDataLayerModel(event));

  @override
  Stream<LauncherSettings> get launcherSettings =>
      settingsClient.launcherSettings
          .map((event) => LauncherSettings.fromDataLayerModel(event));

  @override
  Future<void> updateAppSettings(AppSettings appSettings) {
    return settingsClient.updateAppSettings(appSettings.toDataLayerSettings());
  }

  @override
  Future<void> updateLauncherSettings(LauncherSettings launcherSettings) {
    return settingsClient
        .updateLauncherSettings(launcherSettings.toDataLayerSettings());
  }
}
