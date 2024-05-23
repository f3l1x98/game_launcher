import 'package:database_repository/src/shared/base_model.dart';
import 'package:database_data_layer/database_data_layer.dart' as data_layer;

class DeveloperModel extends BaseModel {
  final String name;
  final String? website;

  DeveloperModel({
    required super.id,
    required this.name,
    this.website,
  });

  DeveloperModel copyWith({
    String? name,
    String? website,
  }) {
    return DeveloperModel(
      id: id,
      name: name ?? this.name,
      // TODO what if setting to null -> would not update
      website: website ?? this.website,
    );
  }

  static DeveloperModel fromDataLayerModel(
    data_layer.DeveloperModel dataLayerModel,
  ) {
    return DeveloperModel(
      id: dataLayerModel.id,
      name: dataLayerModel.name,
      website: dataLayerModel.website,
    );
  }

  data_layer.DeveloperModel toDataLayerModel() {
    return data_layer.DeveloperModel(
      id: id,
      name: name,
      website: website,
    );
  }

  @override
  List<Object?> get props => [...super.props, name, website];
}
