import 'models/models.dart';

abstract class Database {
  // ---------------------------------- Games ----------------------------------
  Future<GameModel> insertGame(GameModel game);

  Future<void> updateGame(GameModel game);

  Future<List<GameModel>> getAllGames();

  Future<List<GameModel>> getNLatestPlayedGames({int n = 10});

  Future<List<GameModel>> searchGames({
    required String searchText,
    required Sorting sorting,
    required bool installedGamesOnly,
    required List<int> includeGenreIds,
    required List<int> excludeGenreIds,
  });

  Future<GameModel?> getGameById(int id);

  Future<bool> deleteGame(GameModel game);

  // ---------------------------------- Genre ----------------------------------
  Future<List<GenreModel>> getAllGenresForGame(int gameId);

  Future<List<GenreModel>> getAllGenres();

  Future<GenreModel?> getGenreById(int id);

  // ------------------------------ GameDeveloper ------------------------------
  Future<List<DeveloperModel>> getAllDevelopers();

  Future<List<DeveloperModel>> getAllDevelopersForGame(int gameId);

  Future<DeveloperModel> insertDeveloper(DeveloperModel developer);

  // ----------------------------- GameSaveProfile -----------------------------
  Future<SaveProfileModel> insertGameSaveProfile(
    SaveProfileModel gameSaveProfile,
  );

  Future<void> updateGameSaveProfile(SaveProfileModel gameSaveProfile);

  Future<List<SaveProfileModel>> getAllGameSaveProfilesForGame(int gameId);

  Future<List<SaveProfileModel>> getAllGameSaveProfiles();
}
