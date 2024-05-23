import 'package:formz/formz.dart';

enum SaveProfileNamePathValidationError {
  required('Name can\'t be empty'),
  invalid('Profile name must be unique');

  final String message;
  const SaveProfileNamePathValidationError(this.message);
}

class SaveProfileName
    extends FormzInput<String?, SaveProfileNamePathValidationError> {
  const SaveProfileName.pure({required this.saveProfileNames})
      : super.pure(null);
  const SaveProfileName.dirty({required this.saveProfileNames, String? value})
      : super.dirty(value);

  final List<String> saveProfileNames;

  @override
  SaveProfileNamePathValidationError? validator(String? value) {
    return value == null || value.isEmpty
        ? SaveProfileNamePathValidationError.required
        : (saveProfileNames.any((element) => element == value)
            ? SaveProfileNamePathValidationError.invalid
            : null);
  }
}
