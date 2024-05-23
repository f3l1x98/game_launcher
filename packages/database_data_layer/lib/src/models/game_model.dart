import 'package:database_data_layer/src/models/game_engine_enum.dart';

class GameModel {
  int id;
  String name;
  String description;
  String version;
  String language;
  int voting;
  List<int> developerIds;
  GameEngineEnum usedGameEngineEnum;
  List<int> genreIds;
  List<int> saveProfileIds;

  int? prequelId;
  int? sequelId;
  /*List<int> sideGamesId; // TODO needs m:n mapping table*/

  /// Absolute path to root of this game. MAY CONTAIN TEMPLATE VARIABLES!
  String path; // TODO what if game isnt installed anymore?!?

  /// Absolute path to executable of this game. MAY CONTAIN TEMPLATE VARIABLES!
  String exePath; // TODO what if game isnt installed anymore?!?

  /// Absolute path to saves location for this game. MAY CONTAIN TEMPLATE VARIABLES!
  /// Example ":gamePath/www/save" or "%AppData%/Renpy/test"
  String? savesPath;

  String archiveFileName;

  /// Absolute path to cover location for this game. MAY CONTAIN TEMPLATE VARIABLES!
  /// Default: ":gameLauncherDataPath/metadata/GAME_NAME_SANITIZED"
  String metadataPath;

  /// Absolute path to metadata for this game (like images/cover). MAY CONTAIN TEMPLATE VARIABLES!
  /// Example: ":gameMetadataPath/cover.png", ":gameMetadataPath/cover.jpg"
  String? coverPath;

  /// List of file names of images inside of [metadataPath] that are to be shown as previews
  List<String> images;

  bool hasGuide;

  String? website;

  bool fullSaveAvailable;
  bool installed;
  DateTime? updatedAt;
  DateTime? insertedAt;
  DateTime? lastPlayedAt;

  GameModel({
    required this.id,
    required this.name,
    required this.description,
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

  @override
  bool operator ==(other) {
    if (!(other.runtimeType == GameModel)) {
      return false;
    }
    GameModel otherGame = other as GameModel;
    return id == otherGame.id &&
        name == otherGame.name &&
        description == otherGame.description &&
        version == otherGame.version &&
        language == otherGame.language &&
        hasGuide == otherGame.hasGuide &&
        voting == otherGame.voting &&
        developerIds == otherGame.developerIds &&
        usedGameEngineEnum == otherGame.usedGameEngineEnum &&
        genreIds == otherGame.genreIds &&
        saveProfileIds == otherGame.saveProfileIds &&
        prequelId == otherGame.prequelId &&
        sequelId == otherGame.sequelId &&
        path == otherGame.path &&
        metadataPath == otherGame.metadataPath &&
        exePath == otherGame.exePath &&
        savesPath == otherGame.savesPath &&
        archiveFileName == otherGame.archiveFileName &&
        coverPath == otherGame.coverPath &&
        website == other.website &&
        fullSaveAvailable == other.fullSaveAvailable &&
        installed == other.installed &&
        insertedAt == other.insertedAt &&
        updatedAt == other.updatedAt &&
        lastPlayedAt == other.lastPlayedAt;
  }

  @override
  int get hashCode => Object.hashAll([this]);
}
