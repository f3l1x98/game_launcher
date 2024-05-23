import 'package:database_data_layer/database_data_layer.dart' as data_layer;

enum Sorting {
  newest,
  oldest,
  mostVotes,
  alphabeticalAsc,
  alphabeticalDesc,
}

extension SortingConverter on Sorting {
  static Sorting fromDataLayerModel(
    data_layer.Sorting dataLayerModel,
  ) {
    return Sorting.values.byName(dataLayerModel.name);
  }

  data_layer.Sorting toDataLayerModel() {
    return data_layer.Sorting.values.byName(name);
  }
}
