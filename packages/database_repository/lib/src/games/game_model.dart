import 'package:database_repository/src/game_engines/game_engine_enum.dart';
import 'package:database_repository/src/games/language_enum.dart';
import 'package:database_repository/src/shared/base_model.dart';
import 'package:database_data_layer/database_data_layer.dart' as data_layer;
import 'package:sanitize_filename/sanitize_filename.dart';

class GameModel extends BaseModel {
  // TODO maybe split into separate classes: GameInformationModel, GameFileModel, GameMetadataModel, ...
  final String name;
  final String? description;
  final String version;
  final LanguageEnum language;
  final int voting;
  final List<int> developerIds;
  final GameEngineEnum usedGameEngineEnum;
  final List<int> genreIds;
  final List<int> saveProfileIds;

  final int? prequelId;
  final int? sequelId;
  /*List<int> sideGamesId; // TODO needs m:n mapping table*/

  /// Path to root of this game, localized to the configured rootPath.
  final String path;

  /// Path to executable of this game, localized to the configured rootPath.
  final String exePath;

  /// Path to saves location for this game, localized to the configured rootPath.
  /// Example "/GAME_NAME_SANITIZED/www/save" or "%AppData%/Renpy/test"
  final String? savesPath;

  final String archiveFileName;

  /// Path to the metadata directory of this game, localized to the configured rootPath.
  /// Default: "/.launcherData/metadata/GAME_NAME_SANITIZED"
  final String metadataPath;

  /// Path to metadata for this game (like images/cover), localized to the configured rootPath.
  /// Example: "/.launcherData/metadata/GAME_NAME_SANITIZED/cover.png"
  final String? coverPath;

  /// List of file names of images inside of [metadataPath] that are to be shown as previews
  final List<String> images;

  final bool hasGuide;

  final String? website;

// TODO rename to sth like gameCompleted (however this sounds too much like if the game has been fully released)
  final bool fullSaveAvailable;
  final bool installed;
  final DateTime? updatedAt;
  final DateTime? insertedAt;
  final DateTime? lastPlayedAt;

  // TODO path no longer contains template variables -> path = "${p.separator}${gameDirectoryName}"
  String get gameDirectoryName => sanitizeFilename(name);

  GameModel({
    required super.id,
    required this.name,
    this.description,
    required this.version,
    required this.language,
    this.voting = 0,
    required this.developerIds,
    required this.usedGameEngineEnum,
    required this.genreIds,
    required this.saveProfileIds,
    this.prequelId,
    this.sequelId,
    required this.path,
    required this.metadataPath,
    required this.exePath,
    required this.savesPath,
    required this.archiveFileName,
    this.coverPath,
    this.images = const [],
    this.hasGuide = false,
    this.website,
    this.fullSaveAvailable = false,
    this.installed = false,
    this.insertedAt,
    this.updatedAt,
    this.lastPlayedAt,
  });

  factory GameModel.empty() {
    return GameModel(
      id: -1,
      name: '',
      version: '',
      language: LanguageEnum.english,
      developerIds: [],
      usedGameEngineEnum: GameEngineEnum.custom,
      genreIds: [],
      saveProfileIds: [],
      path: '',
      metadataPath: '',
      exePath: '',
      savesPath: '',
      archiveFileName: '',
    );
  }

  GameModel copyWith({
    String? name,
    String? description,
    String? version,
    LanguageEnum? language,
    int? voting,
    List<int>? developerIds,
    GameEngineEnum? usedGameEngineEnum,
    List<int>? genreIds,
    List<int>? saveProfileIds,
    int? prequelId,
    int? sequelId,
    String? path,
    String? metadataPath,
    String? exePath,
    String? savesPath,
    String? archiveFileName,
    String? coverPath,
    List<String>? images,
    bool? hasGuide,
    String? website,
    bool? fullSaveAvailable,
    bool? installed,
    DateTime? insertedAt,
    DateTime? updatedAt,
    DateTime? lastPlayedAt,
  }) {
    return GameModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      version: version ?? this.version,
      language: language ?? this.language,
      voting: voting ?? this.voting,
      developerIds: developerIds ?? this.developerIds,
      usedGameEngineEnum: usedGameEngineEnum ?? this.usedGameEngineEnum,
      genreIds: genreIds ?? this.genreIds,
      saveProfileIds: saveProfileIds ?? this.saveProfileIds,
      prequelId: prequelId ?? this.prequelId,
      sequelId: sequelId ?? this.sequelId,
      path: path ?? this.path,
      metadataPath: metadataPath ?? this.metadataPath,
      exePath: exePath ?? this.exePath,
      savesPath: savesPath ?? this.savesPath,
      archiveFileName: archiveFileName ?? this.archiveFileName,
      coverPath: coverPath ?? this.coverPath,
      images: images ?? this.images,
      hasGuide: hasGuide ?? this.hasGuide,
      website: website ?? this.website,
      fullSaveAvailable: fullSaveAvailable ?? this.fullSaveAvailable,
      installed: installed ?? this.installed,
      insertedAt: insertedAt ?? this.insertedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  static GameModel fromDataLayerModel(
    data_layer.GameModel dataLayerModel,
  ) {
    return GameModel(
      id: dataLayerModel.id,
      name: dataLayerModel.name,
      description: dataLayerModel.description,
      version: dataLayerModel.version,
      language:
          LanguageEnum.values.byName(dataLayerModel.language.toLowerCase()),
      voting: dataLayerModel.voting,
      developerIds: dataLayerModel.developerIds,
      usedGameEngineEnum: DataLayerConverter.fromDataLayerModel(
        dataLayerModel.usedGameEngineEnum,
      ),
      genreIds: dataLayerModel.genreIds,
      saveProfileIds: dataLayerModel.saveProfileIds,
      prequelId: dataLayerModel.prequelId,
      sequelId: dataLayerModel.sequelId,
      path: dataLayerModel.path,
      metadataPath: dataLayerModel.metadataPath,
      exePath: dataLayerModel.exePath,
      savesPath: dataLayerModel.savesPath,
      archiveFileName: dataLayerModel.archiveFileName,
      coverPath: dataLayerModel.coverPath,
      images: dataLayerModel.images,
      hasGuide: dataLayerModel.hasGuide,
      website: dataLayerModel.website,
      fullSaveAvailable: dataLayerModel.fullSaveAvailable,
      installed: dataLayerModel.installed,
      insertedAt: dataLayerModel.insertedAt,
      updatedAt: dataLayerModel.updatedAt,
      lastPlayedAt: dataLayerModel.lastPlayedAt,
    );
  }

  data_layer.GameModel toDataLayerModel() {
    return data_layer.GameModel(
      id: id,
      name: name,
      description: description ?? "",
      version: version,
      language: language.name,
      voting: voting,
      developerIds: developerIds,
      usedGameEngineEnum: usedGameEngineEnum.toDataLayerModel(),
      genreIds: genreIds,
      saveProfileIds: saveProfileIds,
      prequelId: prequelId,
      sequelId: sequelId,
      path: path,
      metadataPath: metadataPath,
      exePath: exePath,
      savesPath: savesPath,
      archiveFileName: archiveFileName,
      coverPath: coverPath,
      images: images,
      hasGuide: hasGuide,
      website: website,
      fullSaveAvailable: fullSaveAvailable,
      installed: installed,
      insertedAt: insertedAt,
      updatedAt: updatedAt,
      lastPlayedAt: lastPlayedAt,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        name,
        description,
        version,
        language,
        voting,
        developerIds,
        usedGameEngineEnum,
        genreIds,
        saveProfileIds,
        prequelId,
        sequelId,
        path,
        metadataPath,
        exePath,
        savesPath,
        archiveFileName,
        coverPath,
        images,
        hasGuide,
        website,
        fullSaveAvailable,
        installed,
        insertedAt,
        updatedAt,
        lastPlayedAt,
      ];
}
