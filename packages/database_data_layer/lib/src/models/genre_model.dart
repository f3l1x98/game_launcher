class GenreModel {
  int id;
  String name;
  String? description;

  GenreModel({
    required this.id,
    required this.name,
    this.description,
  });

  @override
  bool operator ==(other) {
    if (!(other.runtimeType == GenreModel)) {
      return false;
    }
    GenreModel otherGenre = other as GenreModel;
    return id == otherGenre.id &&
        name == otherGenre.name &&
        description == otherGenre.description;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ description.hashCode;
}
