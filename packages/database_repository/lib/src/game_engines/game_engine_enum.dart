import 'package:database_data_layer/database_data_layer.dart' as data_layer;

enum GameEngineEnum {
  renpy,
  unity,
  unreal,
  rpgmakerXP,
  rpgmakerVX,
  rpgmakerMV,
  rpgmakerMZ,
  rpgmakerVXAce,
  vnmaker,
  wolfRpg,
  custom,
}

extension DataLayerConverter on GameEngineEnum {
  static GameEngineEnum fromDataLayerModel(
    data_layer.GameEngineEnum dataLayerModel,
  ) {
    return GameEngineEnum.values.byName(dataLayerModel.name);
  }

  data_layer.GameEngineEnum toDataLayerModel() {
    return data_layer.GameEngineEnum.values.byName(name);
  }
}
