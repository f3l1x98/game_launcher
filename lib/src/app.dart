import 'package:database_data_layer/database_data_layer.dart';
import 'package:database_repository/database_repository.dart';
import 'package:files_repository/files_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_launcher/src/router.dart';
import 'package:progress_data_layer/progress_data_layer.dart';
import 'package:progress_repository/progress_repository.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:settings_data_layer/settings_data_layer.dart';
import 'package:settings_repository/settings_repository.dart';

class App extends StatefulWidget {
  const App({
    super.key,
    required this.lightTheme,
    required this.darkTheme,
    required this.rxPrefs,
  });

  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final RxSharedPreferences rxPrefs;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AbstractSettingsClient _settingsClient;
  late final Database _database;
  late final ProgressDataLayer _progressDataLayer;

  @override
  void initState() {
    super.initState();

    _settingsClient = SettingsClient(rxPrefs: widget.rxPrefs);
    _database = PostgresDatabase.get();
    _progressDataLayer = ProgressDataLayer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => SettingsRepository(
            settingsClient: _settingsClient,
          ),
        ),
        RepositoryProvider(
          create: (context) => ProgressRepository(
            progressDataLayer: _progressDataLayer,
          ),
        ),
        RepositoryProvider(
          create: (context) => GameDatabaseRepository(database: _database),
        ),
        RepositoryProvider(
          create: (context) => GenreDatabaseRepository(database: _database),
        ),
        RepositoryProvider(
          create: (context) => DeveloperDatabaseRepository(database: _database),
        ),
        RepositoryProvider(
          create: (context) =>
              SaveProfileDatabaseRepository(database: _database),
        ),
        RepositoryProvider(
          create: (context) => GameEngineRepository(),
        ),
        RepositoryProvider(
          lazy: false,
          create: (context) => FilesRepository(
            rootPathStream: _settingsClient.launcherSettings
                .map<String>((event) => event.rootPath),
          ),
        ),
        RepositoryProvider(
          create: (context) => ArchivesRepository(SevenZipArchiver()),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: widget.lightTheme,
        darkTheme: widget.darkTheme,
        themeMode: ThemeMode.dark,
        // TODO
        /*themeMode: settingsProvider.ready &&
                !settingsProvider.getBool(
                  BoolSettingsKey.useDarkModeKey,
                )
            ? ThemeMode.light
            : ThemeMode.dark,*/
      ),
    );
  }
}
