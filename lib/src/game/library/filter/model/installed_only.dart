import 'package:formz/formz.dart';

class InstalledOnly extends FormzInput<bool, void> {
  const InstalledOnly.pure() : super.pure(true);
  const InstalledOnly.dirty([super.value = true]) : super.dirty();

  @override
  void validator(bool value) {}
}
