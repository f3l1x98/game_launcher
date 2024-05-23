import 'package:database_repository/src/developers/developer_model.dart';
import 'package:database_repository/src/shared/database_repository.dart';
import 'package:rxdart/rxdart.dart';

class DeveloperDatabaseRepository extends DatabaseRepository<DeveloperModel> {
  DeveloperDatabaseRepository({required super.database}) {
    _loadDevelopers();
  }

  final BehaviorSubject<List<DeveloperModel>> _all$ =
      BehaviorSubject<List<DeveloperModel>>();
  @override
  Stream<List<DeveloperModel>> get all => _all$.stream;

  int? _getByGameIdStreamId;
  final BehaviorSubject<List<DeveloperModel>> _getByGameId$ =
      BehaviorSubject<List<DeveloperModel>>();
  // TODO destroy subject like GameDatabaseRepository?!?!
  Stream<List<DeveloperModel>> getByGameIdStream(int gameId) {
    _getByGameIdStreamId = gameId;
    _updateGetByGameIdSubject();
    return _getByGameId$.stream;
  }

  void _loadDevelopers() {
    database.getAllDevelopers().then((allDevelopers) => _all$.sink.add(
        allDevelopers
            .map((gameDataLayer) =>
                DeveloperModel.fromDataLayerModel(gameDataLayer))
            .toList()));
  }

  void _updateGetByGameIdSubject() {
    if (_getByGameIdStreamId != null) {
      getByGameId(_getByGameIdStreamId!)
          .then((developers) => _getByGameId$.sink.add(developers));
    }
  }

  @override
  Future<DeveloperModel?> getById(int id) async {
    throw UnimplementedError("Missing support for developer getById");
  }

  // TODO if wanting to use Stream: HOW TO NOTIFY IN CASE GAME GETS UPDATED?!?
  // Game hast List<int> developerIds -> if this list changes it should trigger stream update
  Future<List<DeveloperModel>> getByGameId(int id) async {
    final dataLayerModels = await database.getAllDevelopersForGame(id);
    return dataLayerModels
        .map((dataLayerModel) =>
            DeveloperModel.fromDataLayerModel(dataLayerModel))
        .toList();
  }

  @override
  Future<DeveloperModel> insert(DeveloperModel model) async {
    // TODO if wanting to use Stream: HOW TO NOTIFY IN CASE GAME GETS UPDATED?!?
    // Game hast List<int> developerIds -> if this list changes it should trigger stream update
    throw UnimplementedError("Missing support for developer creation");
  }

  @override
  Future<void> update(DeveloperModel model) async {
    // TODO if wanting to use Stream: HOW TO NOTIFY IN CASE GAME GETS UPDATED?!?
    // Game hast List<int> developerIds -> if this list changes it should trigger stream update
    throw UnimplementedError("Missing support for developer editing");
  }
}
