import 'package:formz/formz.dart';

class DeleteArchive extends FormzInput<bool, void> {
  const DeleteArchive.pure() : super.pure(true);
  const DeleteArchive.dirty([bool value = true]) : super.dirty(value);

  @override
  void validator(bool value) {}
}
