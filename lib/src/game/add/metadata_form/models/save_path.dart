import 'package:formz/formz.dart';

class SavePath extends FormzInput<String?, void> {
  const SavePath.pure() : super.pure(null);
  const SavePath.dirty([String value = '']) : super.dirty(value);

  @override
  void validator(String? value) {}
}
