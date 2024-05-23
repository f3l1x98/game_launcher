import 'package:meta/meta.dart';
import 'package:settings_data_layer/settings_data_layer.dart'
    hide AppSettings, LauncherSettings;
import 'package:settings_repository/src/model/models.dart';

abstract class AbstractSettingsRepository {
  @protected
  final AbstractSettingsClient settingsClient;

  AbstractSettingsRepository({required this.settingsClient});

  Stream<AppSettings> get appSettings;

  Stream<LauncherSettings> get launcherSettings;

  Future<void> updateAppSettings(AppSettings appSettings);
  Future<void> updateLauncherSettings(LauncherSettings launcherSettings);
}
