import 'package:formz/formz.dart';

class Cover extends FormzInput<String?, void> {
  const Cover.pure() : super.pure(null);
  const Cover.dirty([String value = '']) : super.dirty(value);

  @override
  void validator(String? value) {}
}
