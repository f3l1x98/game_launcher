import 'package:database_repository/database_repository.dart';
import 'package:formz/formz.dart';

class Prequel extends FormzInput<GameModel?, void> {
  const Prequel.pure() : super.pure(null);
  const Prequel.dirty([GameModel? value]) : super.dirty(value);

  @override
  void validator(GameModel? value) {}
}
