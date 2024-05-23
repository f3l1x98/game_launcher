import 'package:database_repository/database_repository.dart';
import 'package:formz/formz.dart';

enum EngineValidationError {
  required('Engine can\'t be empty');

  final String message;
  const EngineValidationError(this.message);
}

class Engine extends FormzInput<GameEngineModel?, EngineValidationError> {
  const Engine.pure() : super.pure(null);
  const Engine.dirty([GameEngineModel? value]) : super.dirty(value);

  @override
  EngineValidationError? validator(GameEngineModel? value) {
    return value == null ? EngineValidationError.required : null;
  }
}
