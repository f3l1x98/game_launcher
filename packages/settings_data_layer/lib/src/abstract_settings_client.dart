import 'package:settings_data_layer/src/model/models.dart';

abstract class AbstractSettingsClient {
  final AppSettings defaultAppSettings = AppSettings(
    isFirstStart: true,
    useDarkMode: true,
  );
  static const LauncherSettings defaultLauncherSettings = LauncherSettings(
    rootPath: "",
    /*gameLauncherDataPath: "",
    gamesBasePath: "",
    gamesDeinstalledPath: "",
    gamesMetadataPath: "",
    gamesTmpPath: "",*/
    //zipExecutableDirectoryPath: "",
  );

  Stream<AppSettings> get appSettings;

  Stream<LauncherSettings> get launcherSettings;

  Future<void> updateAppSettings(AppSettings appSettings);
  Future<void> updateLauncherSettings(LauncherSettings launcherSettings);
}
