import 'package:json_annotation/json_annotation.dart';

part 'launcher_settings.g.dart';

@JsonSerializable()
class LauncherSettings {
  final String rootPath;
  /*final String gameLauncherDataPath;
  final String gamesTmpPath;
  final String gamesMetadataPath;
  final String gamesBasePath;
  final String gamesDeinstalledPath;*/
  //final String zipExecutableDirectoryPath;

  const LauncherSettings({
    required this.rootPath,
    /*required this.gameLauncherDataPath,
    required this.gamesTmpPath,
    required this.gamesMetadataPath,
    required this.gamesBasePath,
    required this.gamesDeinstalledPath,*/
    //required this.zipExecutableDirectoryPath,
  });

  factory LauncherSettings.fromJson(Map<String, dynamic> json) =>
      _$LauncherSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$LauncherSettingsToJson(this);
}
