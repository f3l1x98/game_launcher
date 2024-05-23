part of 'select_image_cubit.dart';

final class SelectImageState extends Equatable {
  const SelectImageState({this.filePaths = const []});

  final List<String> filePaths;

  SelectImageState copyWith({
    List<String>? filePaths,
  }) {
    return SelectImageState(
      filePaths: filePaths ?? this.filePaths,
    );
  }

  @override
  List<Object> get props => [filePaths];
}
