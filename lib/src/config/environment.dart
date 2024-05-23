import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:game_launcher/src/config/config.dart';

class Environment {
  factory Environment() {
    return _instance;
  }

  Environment._internal();

  static final Environment _instance = Environment._internal();

  // ignore: constant_identifier_names
  static const String DEV = 'DEV';
  // ignore: constant_identifier_names
  static const String PROD = 'PROD';
  static String? activeEnvironment;
  bool get isDev => activeEnvironment == DEV;
  bool get isProd => activeEnvironment == PROD;

  Config? config;

  Future<void> initConfig(String environment) async {
    activeEnvironment = environment;
    config = await _getConfig(environment);
    //Logger.level = config!.logLevel;
  }

  String loadEnvOrFail(String envKey) {
    String? env = dotenv.env[envKey];
    if (env == null || env.isEmpty) {
      throw Exception("Env $envKey not found!");
    }
    return env;
  }

  Future<Config> _getConfig(String environment) async {
    await dotenv.load(fileName: ".env");
    return Config(
      databaseConfig: DatabaseConfig(
        host: loadEnvOrFail("DATABASE_HOST"),
        port: int.parse(loadEnvOrFail("DATABASE_PORT")),
        database: loadEnvOrFail("DATABASE_DATABASE"),
        password: loadEnvOrFail("DATABASE_PASSWORD"),
        username: loadEnvOrFail("DATABASE_USERNAME"),
      ),
      //logLevel: environment == Environment.PROD ? Level.error : Level.debug,
    );
  }
}
