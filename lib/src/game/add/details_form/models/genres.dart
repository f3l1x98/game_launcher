import 'package:database_repository/database_repository.dart';
import 'package:formz/formz.dart';

class Genres extends FormzInput<List<GenreModel>, void> {
  const Genres.pure() : super.pure(const []);
  const Genres.dirty([List<GenreModel> value = const []]) : super.dirty(value);

  @override
  void validator(List<GenreModel> value) {}
}
