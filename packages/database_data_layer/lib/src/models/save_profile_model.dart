class SaveProfileModel {
  int id;
  String name;
  int gameId;
  bool active;

  /// Version of the game that this save was created for
  String gameVersion;

  SaveProfileModel({
    required this.id,
    required this.name,
    required this.gameId,
    required this.active,
    required this.gameVersion,
  });

  @override
  bool operator ==(other) {
    if (!(other.runtimeType == SaveProfileModel)) {
      return false;
    }
    SaveProfileModel otherGameSaveProfile = other as SaveProfileModel;
    return id == otherGameSaveProfile.id &&
        name == otherGameSaveProfile.name &&
        gameId == otherGameSaveProfile.gameId &&
        active == otherGameSaveProfile.active &&
        gameVersion == otherGameSaveProfile.gameVersion;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      gameId.hashCode ^
      active.hashCode ^
      gameVersion.hashCode;
}
