import 'package:formz/formz.dart';

enum WebsiteValidationError {
  invalid('Invalid url');

  final String message;
  const WebsiteValidationError(this.message);
}

class Website extends FormzInput<String?, WebsiteValidationError> {
  const Website.pure() : super.pure(null);
  const Website.dirty([String value = '']) : super.dirty(value);

  @override
  WebsiteValidationError? validator(String? value) {
    return value == null || value.isEmpty
        ? null
        : (Uri.tryParse(value)?.isAbsolute ?? false)
            ? null
            : WebsiteValidationError.invalid;
  }
}
