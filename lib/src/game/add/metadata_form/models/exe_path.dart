import 'package:formz/formz.dart';

enum ExePathValidationError {
  required('Exe can\'t be empty');

  final String message;
  const ExePathValidationError(this.message);
}

class ExePath extends FormzInput<String?, ExePathValidationError> {
  const ExePath.pure() : super.pure(null);
  const ExePath.dirty([String value = '']) : super.dirty(value);

  @override
  ExePathValidationError? validator(String? value) {
    return value == null || value.isEmpty
        ? ExePathValidationError.required
        : null;
  }
}
