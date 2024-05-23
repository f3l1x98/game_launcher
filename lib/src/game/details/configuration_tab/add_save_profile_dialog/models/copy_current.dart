import 'package:formz/formz.dart';

class CopyCurrent extends FormzInput<bool, void> {
  const CopyCurrent.pure() : super.pure(false);
  const CopyCurrent.dirty([bool value = false]) : super.dirty(value);

  @override
  void validator(bool value) {}
}
