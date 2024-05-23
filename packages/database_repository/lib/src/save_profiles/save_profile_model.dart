import 'package:database_data_layer/database_data_layer.dart' as data_layer;
import 'package:database_repository/src/shared/base_model.dart';
import 'package:sanitize_filename/sanitize_filename.dart';

class SaveProfileModel extends BaseModel {
  final String name;
  final int gameId;
  final bool active;

  /// Version of the game that this save was created for
  final String gameVersion;

  String get profileDirectoryName => sanitizeFilename(name);

  SaveProfileModel({
    required super.id,
    required this.name,
    required this.gameId,
    required this.active,
    required this.gameVersion,
  });
  SaveProfileModel.create({
    required this.name,
    required this.gameId,
    required this.active,
    required this.gameVersion,
  }) : super(id: -1);

  SaveProfileModel copyWith({
    String? name,
    int? gameId,
    bool? active,
    String? gameVersion,
  }) {
    return SaveProfileModel(
      id: id,
      name: name ?? this.name,
      gameId: gameId ?? this.gameId,
      active: active ?? this.active,
      gameVersion: gameVersion ?? this.gameVersion,
    );
  }

  static SaveProfileModel fromDataLayerModel(
    data_layer.SaveProfileModel dataLayerModel,
  ) {
    return SaveProfileModel(
      id: dataLayerModel.id,
      name: dataLayerModel.name,
      gameId: dataLayerModel.gameId,
      active: dataLayerModel.active,
      gameVersion: dataLayerModel.gameVersion,
    );
  }

  data_layer.SaveProfileModel toDataLayerModel() {
    return data_layer.SaveProfileModel(
      id: id,
      name: name,
      gameId: gameId,
      active: active,
      gameVersion: gameVersion,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        name,
        gameId,
        active,
        gameVersion,
      ];
}
