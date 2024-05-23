part of 'add_save_profile_cubit.dart';

final class AddSaveProfileState extends Equatable {
  const AddSaveProfileState({
    this.status = FormzSubmissionStatus.initial,
    this.saveProfileName = const SaveProfileName.pure(saveProfileNames: []),
    this.copyCurrentSave = const CopyCurrent.pure(),
    this.isValid = false,
  });

  final FormzSubmissionStatus status;
  final SaveProfileName saveProfileName;
  final CopyCurrent copyCurrentSave;
  final bool isValid;

  AddSaveProfileState copyWith({
    FormzSubmissionStatus? status,
    SaveProfileName? saveProfileName,
    CopyCurrent? copyCurrentSave,
    bool? isValid,
  }) {
    return AddSaveProfileState(
      status: status ?? this.status,
      saveProfileName: saveProfileName ?? this.saveProfileName,
      copyCurrentSave: copyCurrentSave ?? this.copyCurrentSave,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object> get props => [
        status,
        saveProfileName,
        copyCurrentSave,
        isValid,
      ];
}
