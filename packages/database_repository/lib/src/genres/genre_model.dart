import 'package:database_repository/src/shared/base_model.dart';
import 'package:database_data_layer/database_data_layer.dart' as data_layer;

class GenreModel extends BaseModel {
  final String name;
  final String? description;

  GenreModel({
    required super.id,
    required this.name,
    this.description,
  });

  GenreModel copyWith({
    String? name,
    String? description,
  }) {
    return GenreModel(
      id: id,
      name: name ?? this.name,
      // TODO what if setting to null -> would not update
      description: description ?? this.description,
    );
  }

  static GenreModel fromDataLayerModel(
    data_layer.GenreModel dataLayerModel,
  ) {
    return GenreModel(
      id: dataLayerModel.id,
      name: dataLayerModel.name,
      description: dataLayerModel.description,
    );
  }

  data_layer.GenreModel toDataLayerModel() {
    return data_layer.GenreModel(
      id: id,
      name: name,
      description: description,
    );
  }

  @override
  List<Object?> get props => [...super.props, name, description];
}
