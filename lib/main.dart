import 'dart:convert';

import 'package:database_data_layer/database_data_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_launcher/src/app.dart';
import 'package:game_launcher/src/config/environment.dart';
import 'package:json_theme/json_theme.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';

Future<ThemeData> loadAppainterTheme(String asset) async {
  final themeStr = await rootBundle.loadString(asset);
  final themeJson = jsonDecode(themeStr);
  return ThemeDecoder.decodeThemeData(themeJson)!;
}

void main() async {
  const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: Environment.DEV,
  );

  await Environment().initConfig(environment);

  PostgresDatabase db = PostgresDatabase.get();
  final dbConfig = Environment().config!.databaseConfig;
  await db.init(
    host: dbConfig.host,
    port: dbConfig.port,
    database: dbConfig.database,
    username: dbConfig.username,
    password: dbConfig.password,
  );
  await db.migrate();

  WidgetsFlutterBinding.ensureInitialized();
  // TODO configure using https://appainter.dev/#/
  // Current seed color: #00BF6D
  final lightTheme =
      await loadAppainterTheme('assets/themes/appainter_light_theme.json');
  final darkTheme =
      await loadAppainterTheme('assets/themes/appainter_dark_theme.json');

  final rxPrefs = RxSharedPreferences.getInstance();

  runApp(App(
    lightTheme: lightTheme,
    darkTheme: darkTheme,
    rxPrefs: rxPrefs,
  ));
}
