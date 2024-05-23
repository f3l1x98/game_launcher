import 'package:equatable/equatable.dart';
import 'package:settings_data_layer/settings_data_layer.dart' as data_layer;

class LauncherSettings extends Equatable {
  /*final String gameLauncherDataPath;
  final String gamesTmpPath;
  final String gamesMetadataPath;
  final String gamesBasePath;
  final String gamesDeinstalledPath;
  final String zipExecutableDirectoryPath;*/
  final String rootPath;

  LauncherSettings({
    required this.rootPath,
  });

  static LauncherSettings fromDataLayerModel(
    data_layer.LauncherSettings dataLayerSettings,
  ) {
    return LauncherSettings(
      rootPath: dataLayerSettings.rootPath,
    );
  }

  data_layer.LauncherSettings toDataLayerSettings() {
    return data_layer.LauncherSettings(
      rootPath: rootPath,
    );
  }

  @override
  List<Object?> get props => [
        rootPath,
      ];
}
