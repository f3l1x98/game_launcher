import 'package:formz/formz.dart';

enum CoverValidationError {
  required('Cover can\'t be empty');
  // TODO perhaps add notFound and invalid (wrong extension)

  final String message;
  const CoverValidationError(this.message);
}

class Cover extends FormzInput<String?, CoverValidationError> {
  const Cover.pure() : super.pure(null);
  const Cover.dirty([String value = '']) : super.dirty(value);

  @override
  CoverValidationError? validator(String? value) {
    // TODO really required?!?!?
    return value == null || value.isEmpty
        ? CoverValidationError.required
        : null;
  }
}
