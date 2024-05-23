import 'package:formz/formz.dart';

class Description extends FormzInput<String?, void> {
  const Description.pure() : super.pure(null);
  const Description.dirty([String value = '']) : super.dirty(value);

  @override
  void validator(String? value) {}
}
