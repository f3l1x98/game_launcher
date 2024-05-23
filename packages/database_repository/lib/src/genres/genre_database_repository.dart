import 'package:database_repository/src/genres/genre_model.dart';
import 'package:database_repository/src/shared/database_repository.dart';
import 'package:rxdart/rxdart.dart';

class GenreDatabaseRepository extends DatabaseRepository<GenreModel> {
  GenreDatabaseRepository({required super.database}) {
    _loadGenres();
  }

  final BehaviorSubject<List<GenreModel>> _all$ =
      BehaviorSubject<List<GenreModel>>();
  @override
  Stream<List<GenreModel>> get all => _all$.stream;

  int? _getByGameIdStreamId;
  final BehaviorSubject<List<GenreModel>> _getByGameId$ =
      BehaviorSubject<List<GenreModel>>();
  // TODO destroy subject like GameDatabaseRepository?!?!
  Stream<List<GenreModel>> getByGameIdStream(int gameId) {
    _getByGameIdStreamId = gameId;
    _updateGetByGameIdSubject();
    return _getByGameId$.stream;
  }

  void _loadGenres() {
    database.getAllGenres().then((allGenres) => _all$.sink.add(allGenres
        .map((gameDataLayer) => GenreModel.fromDataLayerModel(gameDataLayer))
        .toList()));
  }

  void _updateGetByGameIdSubject() {
    if (_getByGameIdStreamId != null) {
      getByGameId(_getByGameIdStreamId!)
          .then((genres) => _getByGameId$.sink.add(genres));
    }
  }

  @override
  Future<GenreModel?> getById(int id) async {
    final dataLayerModel = await database.getGenreById(id);
    return dataLayerModel == null
        ? null
        : GenreModel.fromDataLayerModel(dataLayerModel);
  }

  // TODO if wanting to use Stream: HOW TO NOTIFY IN CASE GAME GETS UPDATED?!?
  // Game hast List<int> genreIds -> if this list changes it should trigger stream update
  Future<List<GenreModel>> getByGameId(int id) async {
    final dataLayerModels = await database.getAllGenresForGame(id);
    return dataLayerModels
        .map((dataLayerModel) => GenreModel.fromDataLayerModel(dataLayerModel))
        .toList();
  }

  @override
  Future<GenreModel> insert(GenreModel model) async {
    // TODO if wanting to use Stream: HOW TO NOTIFY IN CASE GAME GETS UPDATED?!?
    // Game hast List<int> genreIds -> if this list changes it should trigger stream update
    throw UnimplementedError("Missing support for genre creation");
  }

  @override
  Future<void> update(GenreModel model) async {
    // TODO if wanting to use Stream: HOW TO NOTIFY IN CASE GAME GETS UPDATED?!?
    // Game hast List<int> genreIds -> if this list changes it should trigger stream update
    throw UnimplementedError("Missing support for genre editing");
  }
}
