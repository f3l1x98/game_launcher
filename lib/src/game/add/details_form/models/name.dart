import 'package:formz/formz.dart';

enum NameValidationError {
  required('Name can\'t be empty');

  final String message;
  const NameValidationError(this.message);
}

class Name extends FormzInput<String?, NameValidationError> {
  const Name.pure() : super.pure(null);
  const Name.dirty([String value = '']) : super.dirty(value);

  @override
  NameValidationError? validator(String? value) {
    return value == null || value.isEmpty ? NameValidationError.required : null;
  }
}
