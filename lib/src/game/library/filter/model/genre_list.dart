import 'package:database_repository/database_repository.dart';
import 'package:formz/formz.dart';

enum GenreListValidationError { empty }

class GenreList extends FormzInput<List<GenreModel>, GenreListValidationError> {
  const GenreList.pure() : super.pure(const []);
  const GenreList.dirty([super.value = const []]) : super.dirty();

  @override
  GenreListValidationError? validator(List<GenreModel> value) {
    return null;
  }
}
