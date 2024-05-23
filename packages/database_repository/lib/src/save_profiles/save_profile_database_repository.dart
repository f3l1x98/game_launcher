import 'package:database_repository/src/save_profiles/save_profile_model.dart';
import 'package:database_repository/src/shared/database_repository.dart';
import 'package:rxdart/rxdart.dart';

class SaveProfileDatabaseRepository
    extends DatabaseRepository<SaveProfileModel> {
  SaveProfileDatabaseRepository({required super.database}) {
    _loadSaveProfiles();
  }

  final BehaviorSubject<List<SaveProfileModel>> _all$ =
      BehaviorSubject<List<SaveProfileModel>>();
  @override
  Stream<List<SaveProfileModel>> get all => _all$.stream;

  int? _getByGameIdStreamId;
  final BehaviorSubject<List<SaveProfileModel>> _getByGameId$ =
      BehaviorSubject<List<SaveProfileModel>>();
  // TODO destroy subject like GameDatabaseRepository?!?!
  Stream<List<SaveProfileModel>> getByGameIdStream(int gameId) {
    _getByGameIdStreamId = gameId;
    _updateGetByGameIdSubject();
    return _getByGameId$.stream;
  }

  void _loadSaveProfiles() {
    database.getAllGameSaveProfiles().then((allSaveProfiles) => _all$.sink.add(
        allSaveProfiles
            .map((gameDataLayer) =>
                SaveProfileModel.fromDataLayerModel(gameDataLayer))
            .toList()));
  }

  void _updateGetByGameIdSubject() {
    if (_getByGameIdStreamId != null) {
      getByGameId(_getByGameIdStreamId!)
          .then((saveProfiles) => _getByGameId$.sink.add(saveProfiles));
    }
  }

  @override
  Future<SaveProfileModel?> getById(int id) async {
    throw UnimplementedError("Missing support for developer getById");
  }

  // TODO if wanting to use Stream: HOW TO NOTIFY IN CASE GAME GETS UPDATED?!?
  // Game hast List<int> saveProfileIds -> if this list changes it should trigger stream update
  Future<List<SaveProfileModel>> getByGameId(int id) async {
    final dataLayerModels = await database.getAllGameSaveProfilesForGame(id);
    return dataLayerModels
        .map((dataLayerModel) =>
            SaveProfileModel.fromDataLayerModel(dataLayerModel))
        .toList();
  }

  @override
  Future<SaveProfileModel> insert(SaveProfileModel model) async {
    final dataLayerModel =
        await database.insertGameSaveProfile(model.toDataLayerModel());

    _loadSaveProfiles();
    if (model.gameId == _getByGameIdStreamId) {
      _updateGetByGameIdSubject();
    }

    return SaveProfileModel.fromDataLayerModel(dataLayerModel);
  }

  @override
  Future<void> update(SaveProfileModel model) async {
    await database.updateGameSaveProfile(model.toDataLayerModel());

    _loadSaveProfiles();
    if (model.gameId == _getByGameIdStreamId) {
      _updateGetByGameIdSubject();
    }
  }
}
