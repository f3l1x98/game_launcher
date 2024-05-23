import 'package:formz/formz.dart';

class DeleteMetadata extends FormzInput<bool, void> {
  const DeleteMetadata.pure() : super.pure(true);
  const DeleteMetadata.dirty([bool value = true]) : super.dirty(value);

  @override
  void validator(bool value) {}
}
