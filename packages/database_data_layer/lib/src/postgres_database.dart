import 'dart:io';

import 'package:database_data_layer/src/database.dart';
import 'package:migrant/migrant.dart' hide Database;
import 'package:migrant/migrant.dart' as migrant;
import 'package:migrant_db_postgresql/migrant_db_postgresql.dart';
import 'package:migrant_source_fs/migrant_source_fs.dart';
import 'package:postgres/postgres.dart';

import 'models/models.dart';

class PostgresDatabase extends Database {
  late PostgreSQLConnection _connection;

  // TODO relativ path not working, because relative path is relativ to working dir which gets changed by FilePicker
  static const String MIGRATIONS_PATH =
      "G:\\felix\\Documents\\FlutterProjects\\game_launcher\\packages\\database_data_layer\\migrations";
  static const String GAME_TABLE_NAME = "game";
  static const String GAME_GENRE_TABLE_NAME = "game_genre";
  static const String GENRE_TABLE_NAME = "genre";
  static const String DEVELOPER_TABLE_NAME = "developer";
  static const String GAME_DEVELOPER_TABLE_NAME = "game_developer";
  static const String SAVE_PROFILE_TABLE_NAME = "save_profile";

  // ---------------------------------- Games ----------------------------------
  // TODO perhaps move prequel_id and sequel_id into separate m:n table (table with only prequel_id and sequel_id cols -> no need to update both sides)
  final String _allGameColumns =
      """
    g.id, g.name, g.description, g.version, g.language, g.voting, g.prequel_id, g.sequel_id, g.path, g.metadata_path, 
    g.exe_path, g.saves_path, g.archive_filename, g.cover_path, g.images, g.has_guide, g.website, g.full_save_available, 
    g.installed, g.used_gameengine_enum, g.inserted_at, g.updated_at, g.last_played_at, 
    ARRAY_AGG(DISTINCT gg.genre_id) FILTER (WHERE gg.genre_id IS NOT NULL) as genre_ids, 
    ARRAY_AGG(DISTINCT gd.developer_id) FILTER (WHERE gd.developer_id IS NOT NULL) as developer_ids, 
    ARRAY_AGG(DISTINCT gs.id) FILTER (WHERE gs.id IS NOT NULL) as save_profile_ids
  """;
  GameModel _gameModelFromAllGameColumns(PostgreSQLResultRow row) {
    return GameModel(
      id: row[0],
      name: row[1],
      description: row[2],
      version: row[3],
      language: row[4],
      voting: row[5],
      prequelId: row[6],
      sequelId: row[7],
      path: row[8],
      metadataPath: row[9],
      exePath: row[10],
      savesPath: row[11],
      archiveFileName: row[12],
      coverPath: row[13],
      images: row[14],
      hasGuide: row[15],
      website: row[16],
      fullSaveAvailable: row[17],
      installed: row[18],
      usedGameEngineEnum: GameEngineEnum.values.byName(row[19]),
      insertedAt: row[20],
      updatedAt: row[21],
      lastPlayedAt: row[22],
      genreIds: row[23] ?? [],
      developerIds: row[24] ?? [],
      saveProfileIds: row[25] ?? [],
    );
  }

  String _getOrderByFromSorting(Sorting sort) {
    switch (sort) {
      case Sorting.newest:
        return "g.inserted_at DESC";
      case Sorting.oldest:
        return "g.inserted_at ASC";
      case Sorting.mostVotes:
        return "g.voting DESC";
      case Sorting.alphabeticalAsc:
        return "g.name ASC";
      case Sorting.alphabeticalDesc:
        return "g.name DESC";
    }
  }

  Future<dynamic> transactionWrapper(
    Future<dynamic> Function(PostgreSQLExecutionContext) queryBlock, {
    PostgreSQLExecutionContext? transactionContext,
  }) {
    if (transactionContext == null) {
      return _connection.transaction(queryBlock);
    } else {
      return queryBlock(transactionContext);
    }
  }

  @override
  Future<GameModel> insertGame(
    GameModel game, {
    PostgreSQLExecutionContext? transactionContext,
  }) async {
    // TODO error handling
    int newGameId = await _connection.transaction((ctx) async {
      var result = await ctx
          .query("""
          INSERT INTO public.$GAME_TABLE_NAME (name, description, version, language, voting, prequel_id, sequel_id, path, metadata_path, exe_path, saves_path, archive_filename, cover_path, images, has_guide, website, used_gameengine_enum, full_save_available, installed) 
          VALUES (@name, @description, @version, @language, @voting, @prequelId, @sequelId, @path, @metadataPath, @exePath, @savesPath, @archiveFileName, @coverPath, @images, @hasGuide, @website, @usedGameEngineEnum, @fullSaveAvailable, @installed) RETURNING id
          """,
              substitutionValues: {
            "name": game.name,
            "description": game.description,
            "version": game.version,
            "language": game.language,
            "voting": game.voting,
            "prequelId": game.prequelId,
            "sequelId": game.sequelId,
            "path": game.path,
            "metadataPath": game.metadataPath,
            "exePath": game.exePath,
            "savesPath": game.savesPath,
            "archiveFileName": game.archiveFileName,
            "coverPath": game.coverPath,
            "images": game.images,
            "hasGuide": game.hasGuide,
            "website": game.website,
            "usedGameEngineEnum": game.usedGameEngineEnum.name,
            "fullSaveAvailable": game.fullSaveAvailable,
            "installed": game.installed,
          });
      int gameId = result.first[0];
      // Insert other side of pre-/sequel relation
      if (game.prequelId != null) {
        ctx.query(
          """UPDATE public.$GAME_TABLE_NAME SET sequel_id = @sequelId WHERE id = @prequelId""",
          substitutionValues: {
            "sequelId": gameId,
            "prequelId": game.prequelId,
          },
        );
      }
      if (game.sequelId != null) {
        ctx.query(
          """UPDATE public.$GAME_TABLE_NAME SET prequel_id = @prequelId WHERE id = @sequelId""",
          substitutionValues: {
            "prequelId": gameId,
            "sequelId": game.sequelId,
          },
        );
      }
      // Insert Genre relations into m:n tables
      for (int genreId in game.genreIds) {
        await ctx.query(
            "INSERT INTO public.$GAME_GENRE_TABLE_NAME (game_id, genre_id) VALUES (@gameId, @genreId)",
            substitutionValues: {
              "gameId": gameId,
              "genreId": genreId,
            });
      }
      // Insert Developer relations into m:n tables
      for (int developerId in game.developerIds) {
        await ctx.query(
            "INSERT INTO public.$GAME_DEVELOPER_TABLE_NAME (game_id, developer_id) VALUES (@gameId, @developerId)",
            substitutionValues: {
              "gameId": gameId,
              "developerId": developerId,
            });
      }
      return gameId;
    });
    game.id = newGameId;
    return game;
  }

  @override
  Future<void> updateGame(GameModel game) async {
    await _connection.transaction((ctx) async {
      // Unset current pre-/sequel relations
      // Clear sequel
      ctx.query(
        """UPDATE public.$GAME_TABLE_NAME SET prequel_id = NULL WHERE id = (SELECT sequel_id FROM public.$GAME_TABLE_NAME WHERE id = @id)""",
        substitutionValues: {
          "id": game.id,
        },
      );
      // Clear prequel
      ctx.query(
        """UPDATE public.$GAME_TABLE_NAME SET sequel_id = NULL WHERE id = (SELECT prequel_id FROM public.$GAME_TABLE_NAME WHERE id = @id)""",
        substitutionValues: {
          "id": game.id,
        },
      );

      // Set updated at
      game.updatedAt = DateTime.now();

      // Update game
      await ctx
          .query("""
          UPDATE public.$GAME_TABLE_NAME SET 
          name = @name, description = @description, 
          version = @version, language = @language,
          voting = @voting, prequel_id = @prequelId, sequel_id = @sequelId,
          path = @path, metadata_path = @metadataPath, exe_path = @exePath, 
          saves_path = @savesPath, archive_filename = @archiveFileName, 
          cover_path = @coverPath, images = @images, website = @website, 
          has_guide = @hasGuide, used_gameengine_enum = @usedGameEngineEnum, 
          full_save_available = @fullSaveAvailable, 
          last_played_at = @lastplayedAt:timestamptz, updated_at = @updatedAt:timestamptz, 
          installed = @installed
          WHERE id = @id
          """,
              substitutionValues: {
            "id": game.id,
            "name": game.name,
            "description": game.description,
            "version": game.version,
            "language": game.language,
            "voting": game.voting,
            "prequelId": game.prequelId,
            "sequelId": game.sequelId,
            "path": game.path,
            "metadataPath": game.metadataPath,
            "exePath": game.exePath,
            "savesPath": game.savesPath,
            "archiveFileName": game.archiveFileName,
            "coverPath": game.coverPath,
            "images": game.images,
            "hasGuide": game.hasGuide,
            "website": game.website,
            "usedGameEngineEnum": game.usedGameEngineEnum.name,
            "fullSaveAvailable": game.fullSaveAvailable,
            "installed": game.installed,
            "lastplayedAt": game.lastPlayedAt,
            "updatedAt": game.updatedAt,
          });
      // Insert other side of pre-/sequel relation
      if (game.prequelId != null) {
        ctx.query(
          """UPDATE public.$GAME_TABLE_NAME SET sequel_id = @sequelId WHERE id = @prequelId""",
          substitutionValues: {
            "sequelId": game.id,
            "prequelId": game.prequelId,
          },
        );
      }
      if (game.sequelId != null) {
        ctx.query(
          """UPDATE public.$GAME_TABLE_NAME SET prequel_id = @prequelId WHERE id = @sequelId""",
          substitutionValues: {
            "prequelId": game.id,
            "sequelId": game.sequelId,
          },
        );
      }

      // Insert Genre relations into m:n table
      if (game.genreIds.isEmpty) {
        // No genres for game -> only delete all old db entries
        await ctx.query(
          "DELETE FROM public.$GAME_GENRE_TABLE_NAME WHERE game_id = @gameId",
          substitutionValues: {
            "gameId": game.id,
          },
        );
      } else {
        // Game has genres -> insert new and delete old
        String retainArray = game.genreIds.join(",");
        String insertArray =
            game.genreIds.map((genreId) => "(${game.id},$genreId)").join(",");
        await Future.wait([
          ctx.query(
            """
            INSERT INTO public.$GAME_GENRE_TABLE_NAME (game_id, genre_id) 
            VALUES $insertArray ON CONFLICT (game_id, genre_id) DO NOTHING;
            """,
            substitutionValues: {
              "gameId": game.id,
            },
          ),
          ctx.query(
            """
            DELETE FROM public.$GAME_GENRE_TABLE_NAME
            WHERE game_id = @gameId AND genre_id NOT IN ($retainArray);
            """,
            substitutionValues: {
              "gameId": game.id,
            },
          )
        ]);
      }

      // Insert Developer relations into m:n table
      if (game.developerIds.isEmpty) {
        // No developers for game -> only delete all old db entries
        await ctx.query(
          "DELETE FROM public.$GAME_DEVELOPER_TABLE_NAME WHERE game_id = @gameId",
          substitutionValues: {
            "gameId": game.id,
          },
        );
      } else {
        // Game has developers -> insert new and delete old
        String retainArray = game.developerIds.join(",");
        String insertArray = game.developerIds
            .map((developerId) => "(${game.id},$developerId)")
            .join(",");
        await Future.wait([
          ctx.query(
            """
            INSERT INTO public.$GAME_DEVELOPER_TABLE_NAME (game_id, developer_id) 
            VALUES $insertArray ON CONFLICT (game_id, developer_id) DO NOTHING;
            """,
            substitutionValues: {
              "gameId": game.id,
            },
          ),
          ctx.query(
            """
            DELETE FROM public.$GAME_DEVELOPER_TABLE_NAME
            WHERE game_id = @gameId AND developer_id NOT IN ($retainArray);
            """,
            substitutionValues: {
              "gameId": game.id,
            },
          )
        ]);
      }
    });
  }

  @override
  Future<List<GameModel>> getAllGames() async {
    var result = await _connection.query(
        """
      SELECT $_allGameColumns
      FROM public.$GAME_TABLE_NAME g
      LEFT JOIN public.$GAME_GENRE_TABLE_NAME gg ON g.id = gg.game_id
      LEFT JOIN public.$GAME_DEVELOPER_TABLE_NAME gd ON g.id = gd.game_id
      LEFT JOIN public.$SAVE_PROFILE_TABLE_NAME gs ON g.id = gs.game_id
      GROUP BY g.id
      ORDER BY g.name ASC
    """);

    return result.map((row) => _gameModelFromAllGameColumns(row)).toList();
  }

  @override
  Future<List<GameModel>> getNLatestPlayedGames({int n = 10}) async {
    var result = await _connection.query(
        """
      SELECT $_allGameColumns
      FROM public.$GAME_TABLE_NAME g
      LEFT JOIN public.$GAME_GENRE_TABLE_NAME gg ON g.id = gg.game_id
      LEFT JOIN public.$GAME_DEVELOPER_TABLE_NAME gd ON g.id = gd.game_id
      LEFT JOIN public.$SAVE_PROFILE_TABLE_NAME gs ON g.id = gs.game_id
      WHERE g.last_played_at IS NOT NULL
      GROUP BY g.id
      ORDER BY g.last_played_at DESC
      LIMIT @limit
      """,
        substitutionValues: {"limit": n});

    return result.map((row) => _gameModelFromAllGameColumns(row)).toList();
  }

  @override
  Future<List<GameModel>> searchGames({
    required String searchText,
    required Sorting sorting,
    required bool installedGamesOnly,
    required List<int> includeGenreIds,
    required List<int> excludeGenreIds,
  }) async {
    String optionalWhere = "";
    if (installedGamesOnly) {
      optionalWhere = 'AND g.installed = TRUE ';
    }
    if (includeGenreIds.isNotEmpty) {
      optionalWhere +=
          'AND gg.game_id IN (SELECT DISTINCT gg.game_id FROM public.$GAME_GENRE_TABLE_NAME gg WHERE gg.genre_id IN (${includeGenreIds.join(', ')})) ';
    }
    if (excludeGenreIds.isNotEmpty) {
      optionalWhere +=
          'AND gg.game_id NOT IN (SELECT DISTINCT gg.game_id FROM public.$GAME_GENRE_TABLE_NAME gg WHERE gg.genre_id IN (${excludeGenreIds.join(', ')})) ';
    }
    var result = await _connection
        .query("""
      SELECT DISTINCT $_allGameColumns
      FROM public.$GAME_TABLE_NAME g
      LEFT JOIN public.$GAME_GENRE_TABLE_NAME gg ON g.id = gg.game_id
      LEFT JOIN public.$GAME_DEVELOPER_TABLE_NAME gd ON g.id = gd.game_id
      LEFT JOIN public.$SAVE_PROFILE_TABLE_NAME gs ON g.id = gs.game_id
      WHERE g.name ILIKE @searchText 
      $optionalWhere
      GROUP BY g.id
      ORDER BY ${_getOrderByFromSorting(sorting)}
      """,
            substitutionValues: {
          "searchText": "%$searchText%",
          /* 
      TODO this does not work for some reason!
      Always returns Unhandled Exception: PostgreSQLSeverity.error 42601: syntax error at or near "$2"
      
      AND gg.genre_id IN @includeGenreIds:_int4
      AND gg.genre_id NOT IN @excludeGenreIds:_int4
      
      "includeGenreIds": [
        1
      ], //"(${[1].join(', ')})", //"(${includeGenreIds.join(", ")})",
      "excludeGenreIds": [2], //"(${excludeGenreIds.join(", ")})",*/
        });

    return result.map((row) => _gameModelFromAllGameColumns(row)).toList();
  }

  @override
  Future<GameModel?> getGameById(int id) async {
    var result = await _connection.query(
        """
      SELECT $_allGameColumns
      FROM public.$GAME_TABLE_NAME g
      LEFT JOIN public.$GAME_GENRE_TABLE_NAME gg ON g.id = gg.game_id
      LEFT JOIN public.$GAME_DEVELOPER_TABLE_NAME gd ON g.id = gd.game_id
      LEFT JOIN public.$SAVE_PROFILE_TABLE_NAME gs ON g.id = gs.game_id
      WHERE g.id = $id
      GROUP BY g.id
      """);

    if (result.isEmpty) {
      return null;
    }
    final row = result.first;
    return _gameModelFromAllGameColumns(row);
  }

  @override
  Future<bool> deleteGame(GameModel game) async {
    var result = await _connection.query(
        """
      DELETE FROM public.$GAME_TABLE_NAME g WHERE g.id = ${game.id}
      """);

    if (result.isEmpty) {
      return false;
    }

    return true;
  }

  // ---------------------------------- Genre ----------------------------------
  @override
  Future<List<GenreModel>> getAllGenresForGame(int gameId) async {
    var result = await _connection.query(
        "SELECT g.id, g.name, g.description FROM public.$GENRE_TABLE_NAME g LEFT JOIN public.$GAME_GENRE_TABLE_NAME gg ON g.id = gg.genre_id WHERE gg.game_id = @gameId ORDER BY g.name ASC",
        substitutionValues: {
          "gameId": gameId,
        });
    return result
        .map((row) => GenreModel(
              id: row[0],
              name: row[1],
              description: row[2],
            ))
        .toList();
  }

  @override
  Future<List<GenreModel>> getAllGenres() async {
    var result = await _connection.query(
        "SELECT g.id, g.name, g.description FROM public.$GENRE_TABLE_NAME g ORDER BY g.name ASC");
    return result
        .map((row) => GenreModel(
              id: row[0],
              name: row[1],
              description: row[2],
            ))
        .toList();
  }

  @override
  Future<GenreModel?> getGenreById(int id) async {
    var result = await _connection.query(
        "SELECT g.id, g.name, g.description FROM public.$GENRE_TABLE_NAME g WHERE g.id = $id");

    if (result.isEmpty) {
      return null;
    }
    final row = result.first;
    return GenreModel(
      id: row[0],
      name: row[1],
      description: row[2],
    );
  }

  // ------------------------------ GameDeveloper ------------------------------
  @override
  Future<List<DeveloperModel>> getAllDevelopers() async {
    var result = await _connection.query(
        "SELECT gd.id, gd.name, gd.website FROM public.$DEVELOPER_TABLE_NAME gd ORDER BY gd.name ASC");
    return result
        .map((row) => DeveloperModel(
              id: row[0],
              name: row[1],
              website: row[2],
            ))
        .toList();
  }

  @override
  Future<List<DeveloperModel>> getAllDevelopersForGame(
    int gameId,
  ) async {
    var result = await _connection.query(
        "SELECT gd.id, gd.name, gd.website FROM public.$DEVELOPER_TABLE_NAME gd LEFT JOIN public.$GAME_DEVELOPER_TABLE_NAME ggd ON gd.id = ggd.developer_id WHERE ggd.game_id = @gameId ORDER BY gd.name ASC",
        substitutionValues: {
          "gameId": gameId,
        });
    return result
        .map((row) => DeveloperModel(
              id: row[0],
              name: row[1],
              website: row[2],
            ))
        .toList();
  }

  @override
  Future<DeveloperModel> insertDeveloper(
    DeveloperModel developer,
  ) async {
    var result = await _connection.query(
        "INSERT INTO public.$DEVELOPER_TABLE_NAME (name, website) VALUES (@name, @website) RETURNING id",
        substitutionValues: {
          "name": developer.name,
          "website": developer.website,
        });
    developer.id = result.first[0];
    return developer;
  }

  // ----------------------------- GameSaveProfile -----------------------------
  @override
  Future<SaveProfileModel> insertGameSaveProfile(
    SaveProfileModel gameSaveProfile,
  ) async {
    var result = await _connection
        .query("""
    INSERT INTO public.$SAVE_PROFILE_TABLE_NAME (name, game_id, active, game_version) 
    VALUES (@name, @gameId, @active, @gameVersion) RETURNING id
    """,
            substitutionValues: {
          "name": gameSaveProfile.name,
          "gameId": gameSaveProfile.gameId,
          "active": gameSaveProfile.active,
          "gameVersion": gameSaveProfile.gameVersion,
        });
    gameSaveProfile.id = result.first[0];
    return gameSaveProfile;
  }

  @override
  Future<void> updateGameSaveProfile(
    SaveProfileModel gameSaveProfile,
  ) async {
    await _connection
        .query("""
    UPDATE public.$SAVE_PROFILE_TABLE_NAME SET 
    name = @name, game_id = @gameId, active = @active, game_version = @gameVersion
    WHERE id = @id
    """,
            substitutionValues: {
          "id": gameSaveProfile.id,
          "name": gameSaveProfile.name,
          "gameId": gameSaveProfile.gameId,
          "active": gameSaveProfile.active,
          "gameVersion": gameSaveProfile.gameVersion,
        });
  }

  @override
  Future<List<SaveProfileModel>> getAllGameSaveProfilesForGame(
      int gameId) async {
    var result = await _connection.query(
        "SELECT gsp.id, gsp.name, gsp.game_id, gsp.active, gsp.game_version FROM public.$SAVE_PROFILE_TABLE_NAME gsp WHERE gsp.game_id = @gameId ORDER BY gsp.name ASC",
        substitutionValues: {
          "gameId": gameId,
        });
    return result
        .map((row) => SaveProfileModel(
              id: row[0],
              name: row[1],
              gameId: row[2],
              active: row[3],
              gameVersion: row[4],
            ))
        .toList();
  }

  @override
  Future<List<SaveProfileModel>> getAllGameSaveProfiles() async {
    var result = await _connection.query(
        "SELECT gsp.id, gsp.name, gsp.game_id, gsp.active, gsp.game_version FROM public.$SAVE_PROFILE_TABLE_NAME gsp ORDER BY gsp.name ASC");
    return result
        .map((row) => SaveProfileModel(
              id: row[0],
              name: row[1],
              gameId: row[2],
              active: row[3],
              gameVersion: row[4],
            ))
        .toList();
  }

  // Migrations
  Future<void> migrate({bool close = false}) async {
    // Migration files must start with capital V and 3 digits which define the version.
    final fileNameFormat = FileNameFormat(RegExp(r'[V]\d{3}'));

    // Reading migrations from this directory.
    // Try adding more migrations in there!
    final directory = Directory(MIGRATIONS_PATH);

    // Migration source.
    final migrations = LocalDirectory(directory, fileNameFormat);

    // The gateway is provided by this package.
    final gateway = PostgreSQLGateway(_connection);

    // Extra capabilities may be added like this. See the implementation below.
    final loggingGateway = LoggingGatewayWrapper(gateway);

    // Applying migrations.
    await migrant.Database(loggingGateway).migrate(migrations);

    if (close) {
      // Close after migrations are done
      await _connection.close();
    }
  }

  // singleton stuff
  static PostgresDatabase? _instance;

  static PostgresDatabase get() {
    _instance ??= PostgresDatabase._();
    return _instance!;
  }

  Future<void> init({
    required String host,
    required int port,
    required String database,
    required String? username,
    required String? password,
  }) async {
    _connection = PostgreSQLConnection(
      host,
      port,
      database,
      username: username,
      password: password,
    );
    if (_connection.isClosed) {
      await _connection.open();
    }
  }

  PostgresDatabase._();
}

class LoggingGatewayWrapper implements DatabaseGateway {
  LoggingGatewayWrapper(this.gateway);

  final DatabaseGateway gateway;

  @override
  Future<void> apply(Migration migration) async {
    print('Applying version ${migration.version}...');
    gateway.apply(migration);
    print('Version ${migration.version} has been applied.');
  }

  @override
  Future<String?> currentVersion() async {
    final version = await gateway.currentVersion();
    print('The database is at version $version.');
    return version;
  }
}
