part of 'select_archive_cubit.dart';

final class SelectArchiveState extends Equatable {
  const SelectArchiveState({this.filePath});

  final String? filePath;

  SelectArchiveState copyWith({
    String? filePath,
  }) {
    // TODO what if you want to unset the filePath
    return SelectArchiveState(
      filePath: filePath,
    );
  }

  @override
  List<Object> get props => [];
}
