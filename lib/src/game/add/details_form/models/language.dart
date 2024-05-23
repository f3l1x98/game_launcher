import 'package:database_repository/database_repository.dart';
import 'package:formz/formz.dart';

class Language extends FormzInput<LanguageEnum, void> {
  const Language.pure() : super.pure(LanguageEnum.english);
  const Language.dirty([LanguageEnum value = LanguageEnum.english])
      : super.dirty(value);

  @override
  void validator(LanguageEnum value) {}
}
