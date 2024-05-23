import 'package:formz/formz.dart';

enum VersionValidationError {
  required('Version can\'t be empty'),
  invalid('Invalid version');

  final String message;
  const VersionValidationError(this.message);
}

class Version extends FormzInput<String?, VersionValidationError> {
  const Version.pure() : super.pure(null);
  const Version.dirty([String value = '']) : super.dirty(value);

  static final RegExp regexMatcher = RegExp(r'[vV]?\d+(\.\d+)+[a-zA-Z]?$');

  @override
  VersionValidationError? validator(String? value) {
    return value == null || value.isEmpty
        ? VersionValidationError.required
        : regexMatcher.hasMatch(value)
            ? null
            : VersionValidationError.invalid;
  }
}
