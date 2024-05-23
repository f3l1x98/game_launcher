import 'package:formz/formz.dart';

/*enum ImagesValidationError {
  // TODO perhaps add notFound and invalid (wrong extension)

  final String message;
  const ImagesValidationError(this.message);
}*/

class Images extends FormzInput<List<String>, void> {
  const Images.pure() : super.pure(const []);
  const Images.dirty([List<String> value = const []]) : super.dirty(value);

  @override
  void validator(List<String> value) {}
}
