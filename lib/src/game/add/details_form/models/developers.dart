import 'package:database_repository/database_repository.dart';
import 'package:formz/formz.dart';

class Developers extends FormzInput<List<DeveloperModel>, void> {
  const Developers.pure() : super.pure(const []);
  const Developers.dirty([List<DeveloperModel> value = const []])
      : super.dirty(value);

  @override
  void validator(List<DeveloperModel> value) {
    // TODO this would need to look whether each entry is a valid developer id
    // HOWEVER THE UI SHOULD PREVENT THIS (after all the input is somekind of dropdown like input)
  }
}
