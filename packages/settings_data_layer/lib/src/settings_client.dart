import 'dart:convert';

import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings_data_layer/src/abstract_settings_client.dart';
import 'package:settings_data_layer/src/model/models.dart';

class SettingsClient extends AbstractSettingsClient {
  final RxSharedPreferences _rxPrefs;

  SettingsClient({required RxSharedPreferences rxPrefs}) : _rxPrefs = rxPrefs {
    _launcherSettings$.addStream(_rxPrefs
        .getStringStream("LAUNCHER_SETTINGS")
        .map(parseLauncherSettings));
  }
  final BehaviorSubject<LauncherSettings> _launcherSettings$ =
      BehaviorSubject<LauncherSettings>.seeded(
          AbstractSettingsClient.defaultLauncherSettings);

  @override
  Stream<AppSettings> get appSettings =>
      _rxPrefs.getStringStream("APP_SETTINGS").map((event) => event == null
          ? defaultAppSettings // TODO UNSURE IF THAT BREAKS AT SOME POINT
          : AppSettings.fromJson(jsonDecode(event)));

  @override
  Stream<LauncherSettings> get launcherSettings => _launcherSettings$.stream;

  LauncherSettings parseLauncherSettings(String? event) {
    return event == null
        ? AbstractSettingsClient
            .defaultLauncherSettings // TODO UNSURE IF THAT BREAKS AT SOME POINT
        : LauncherSettings.fromJson(jsonDecode(event));
  }

  @override
  Future<void> updateAppSettings(AppSettings appSettings) {
    return _rxPrefs.setString("APP_SETTINGS", jsonEncode(appSettings.toJson()));
  }

  @override
  Future<void> updateLauncherSettings(LauncherSettings launcherSettings) {
    return _rxPrefs.setString(
        "LAUNCHER_SETTINGS", jsonEncode(launcherSettings.toJson()));
  }
}
