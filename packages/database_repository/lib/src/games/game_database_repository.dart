import 'package:database_repository/database_repository.dart';
import 'package:database_repository/src/games/game_model.dart';
import 'package:database_repository/src/shared/database_repository.dart';
import 'package:database_repository/src/shared/exceptions/not_found_exception.dart';
import 'package:database_repository/src/shared/sorting_enum.dart';
import 'package:rxdart/rxdart.dart';

class GameDatabaseRepository extends DatabaseRepository<GameModel> {
  GameDatabaseRepository({required super.database}) {
    _loadGames();
  }

  final BehaviorSubject<List<GameModel>> _latestPlayedGames$ =
      BehaviorSubject<List<GameModel>>();
  Stream<List<GameModel>> get latestPlayedGames => _latestPlayedGames$.stream;

  final BehaviorSubject<List<GameModel>> _all$ =
      BehaviorSubject<List<GameModel>>();
  @override
  Stream<List<GameModel>> get all => _all$.stream;

  int? _getByIdStreamId;
  BehaviorSubject<GameModel> _getById$ = BehaviorSubject<GameModel>();
  Stream<GameModel> getByIdStream(int gameId) {
    if (_getByIdStreamId != gameId) {
      // Reset subject to get rid of old GameModel
      // TODO either that or improve BlocBuilder update behavior in DetailsScreen
      _getById$.close();
      _getById$ = BehaviorSubject<GameModel>();

      _getByIdStreamId = gameId;
    }
    _updateGetByIdSubject();
    return _getById$.stream;
  }

  void _loadGames() {
    database.getAllGames().then((allGames) => _all$.sink.add(allGames
        .map((gameDataLayer) => GameModel.fromDataLayerModel(gameDataLayer))
        .toList()));
    database.getNLatestPlayedGames().then((allGames) => _latestPlayedGames$.sink
        .add(allGames
            .map((gameDataLayer) => GameModel.fromDataLayerModel(gameDataLayer))
            .toList()));
  }

  _updateGetByIdSubject() {
    if (_getByIdStreamId != null) {
      getById(_getByIdStreamId!).then((game) {
        if (game != null) {
          _getById$.sink.add(game);
        } else {
          _getById$.sink
              .addError(NotFoundException("Game with id $_getByIdStreamId"));
        }
      });
    }
  }

  @override
  Future<GameModel?> getById(int id) async {
    final dataLayerModel = await database.getGameById(id);
    return dataLayerModel == null
        ? null
        : GameModel.fromDataLayerModel(dataLayerModel);
  }

  @override
  Future<GameModel> insert(GameModel model) async {
    final dataLayerModel = await database.insertGame(model.toDataLayerModel());

    _loadGames();

    return GameModel.fromDataLayerModel(dataLayerModel);
  }

  @override
  Future<void> update(GameModel model) async {
    await database.updateGame(model.toDataLayerModel());

    _loadGames();
    if (model.id == _getByIdStreamId) {
      _getById$.sink.add(model);
    }
  }

  Future<void> delete(GameModel model) async {
    await database.deleteGame(model.toDataLayerModel());
  }

  // TODO ISSUE:
  //  - Sorting is only in LibraryBloc
  //  - Filters are only in FilterBloc
  //  -> DB call needs both sorting and filters

  String _searchText = '';
  String get searchText => _searchText;
  Sorting _sorting = Sorting.alphabeticalAsc;
  Sorting get sorting => _sorting;
  bool _installedOnly = false;
  bool get installedOnly => _installedOnly;
  List<int> _includedGenreIds = [];
  List<int> get includedGenreIds => _includedGenreIds;
  List<int> _excludedGenreIds = [];
  List<int> get excludedGenreIds => _excludedGenreIds;

  Future<void> filter({
    String? searchText,
    Sorting? sorting,
    bool? installedOnly,
    List<int>? includedGenreIds,
    List<int>? excludedGenreIds,
  }) async {
    _searchText = searchText ?? _searchText;
    _sorting = sorting ?? _sorting;
    _installedOnly = installedOnly ?? _installedOnly;
    _includedGenreIds = includedGenreIds ?? _includedGenreIds;
    _excludedGenreIds = excludedGenreIds ?? _excludedGenreIds;

    // TODO I think this is any genre -> select multiple genre returns any game with at least one of the genres included/excluded
    final games = await database.searchGames(
      searchText: _searchText,
      sorting: _sorting.toDataLayerModel(),
      installedGamesOnly: _installedOnly,
      includeGenreIds: _includedGenreIds,
      excludeGenreIds: _excludedGenreIds,
    );

    _all$.sink
        .add(games.map((game) => GameModel.fromDataLayerModel(game)).toList());
  }

  GameModel? _creationGame;
  GameModel get creationGame => _creationGame != null
      ? _creationGame!
      : throw StateError("CreationGame has not been initialized.");

  // TODO update functions for each part
  // TODO the _creationGame contains absolute paths -> before inserting make them localized
  updateAnalysisResult({
    required String gamePath,
    required String name,
    required GameEngineEnum? gameEngineEnum,
    required String? version,
    required String? absoluteExePath,
    required String? absoluteSavesPath,
  }) {
    _creationGame ??= GameModel.empty();
    _creationGame = _creationGame!.copyWith(
      path: gamePath,
      name: name,
      usedGameEngineEnum: gameEngineEnum,
      version: version,
      savesPath: absoluteSavesPath,
      exePath: absoluteExePath,
    );
  }

  updateMetadataForm({
    required GameEngineEnum gameEngineEnum,
    required String absoluteExePath,
    required String? absoluteSavesPath,
  }) {
    _creationGame ??= GameModel.empty();
    _creationGame = _creationGame!.copyWith(
      usedGameEngineEnum: gameEngineEnum,
      savesPath: absoluteSavesPath,
      exePath: absoluteExePath,
    );
  }

  updateDetailsForm({
    required String? description,
    required List<int> developerIds,
    required List<int> genreIds,
    required LanguageEnum language,
    required String name,
    required int? prequelId,
    required int? sequelId,
    required String version,
    required int voting,
    required String? website,
  }) {
    _creationGame = _creationGame!.copyWith(
      description: description,
      developerIds: developerIds,
      genreIds: genreIds,
      language: language,
      name: name,
      prequelId: prequelId,
      sequelId: sequelId,
      version: version,
      voting: voting,
      website: website,
    );
  }

  updateImagesForm({
    required String? cover,
    required List<String> images,
  }) {
    _creationGame = _creationGame!.copyWith(
      coverPath: cover,
      images: images,
    );
  }
}

class Filter {
  const Filter({
    required this.searchText,
    required this.sorting,
    required this.installedOnly,
    required this.includeGenreIds,
    required this.excludeGenreIds,
  });

  final String searchText;
  final Sorting sorting;
  final bool installedOnly;
  final List<int> includeGenreIds;
  final List<int> excludeGenreIds;
}
