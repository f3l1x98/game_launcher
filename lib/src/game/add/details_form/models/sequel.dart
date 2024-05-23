import 'package:database_repository/database_repository.dart';
import 'package:formz/formz.dart';

class Sequel extends FormzInput<GameModel?, void> {
  const Sequel.pure() : super.pure(null);
  const Sequel.dirty([GameModel? value]) : super.dirty(value);

  @override
  void validator(GameModel? value) {}
}
