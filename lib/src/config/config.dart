class Config {
  DatabaseConfig databaseConfig;
  //Level logLevel; // from package:logger

  Config({
    required this.databaseConfig,
    //required this.logLevel,
  });
}

class DatabaseConfig {
  String host;
  int port;
  String database;
  String username;
  String password;

  DatabaseConfig({
    required this.host,
    required this.port,
    required this.database,
    required this.username,
    required this.password,
  });
}
