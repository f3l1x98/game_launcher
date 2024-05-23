import 'package:equatable/equatable.dart';
import 'package:settings_data_layer/settings_data_layer.dart' as data_layer;

class AppSettings extends Equatable {
  final bool useDarkMode;
  final bool isFirstStart;

  AppSettings({required this.useDarkMode, required this.isFirstStart});

  static AppSettings fromDataLayerModel(
    data_layer.AppSettings dataLayerSettings,
  ) {
    return AppSettings(
      useDarkMode: dataLayerSettings.useDarkMode,
      isFirstStart: dataLayerSettings.isFirstStart,
    );
  }

  data_layer.AppSettings toDataLayerSettings() {
    return data_layer.AppSettings(
      useDarkMode: useDarkMode,
      isFirstStart: isFirstStart,
    );
  }

  @override
  List<Object?> get props => [useDarkMode, isFirstStart];
}
