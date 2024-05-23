import 'package:formz/formz.dart';

enum VotingValidationError {
  invalid('Voting has to be in range 0 to 5');

  final String message;
  const VotingValidationError(this.message);
}

class Voting extends FormzInput<int, VotingValidationError> {
  const Voting.pure() : super.pure(0);
  const Voting.dirty([int value = 0]) : super.dirty(value);

  @override
  VotingValidationError? validator(int value) {
    return value < 0 || value > 5 ? VotingValidationError.invalid : null;
  }
}
