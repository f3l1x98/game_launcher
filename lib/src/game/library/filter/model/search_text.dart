import 'package:formz/formz.dart';

enum SearchTextValidationError { empty }

class SearchText extends FormzInput<String, SearchTextValidationError> {
  const SearchText.pure() : super.pure('');
  const SearchText.dirty([super.value = '']) : super.dirty();

  @override
  SearchTextValidationError? validator(String value) {
    return null;
  }
}
