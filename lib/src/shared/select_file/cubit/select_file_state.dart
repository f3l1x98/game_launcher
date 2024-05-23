part of 'select_file_cubit.dart';

final class SelectFileState extends Equatable {
  const SelectFileState({this.filePath});

  final String? filePath;

  SelectFileState copyWith({
    String? filePath,
  }) {
    // TODO what if you want to unset the filePath
    return SelectFileState(
      filePath: filePath,
    );
  }

  @override
  List<Object> get props => [];
}
