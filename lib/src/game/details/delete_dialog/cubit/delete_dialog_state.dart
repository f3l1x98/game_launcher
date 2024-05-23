part of 'delete_dialog_cubit.dart';

final class DeleteDialogState extends Equatable {
  const DeleteDialogState({
    this.deleteArchive = const DeleteArchive.pure(),
    this.deleteMetadata = const DeleteMetadata.pure(),
  });

  final DeleteArchive deleteArchive;
  final DeleteMetadata deleteMetadata;

  DeleteDialogState copyWith({
    DeleteArchive? deleteArchive,
    DeleteMetadata? deleteMetadata,
  }) {
    return DeleteDialogState(
      deleteArchive: deleteArchive ?? this.deleteArchive,
      deleteMetadata: deleteMetadata ?? this.deleteMetadata,
    );
  }

  @override
  List<Object> get props => [deleteArchive, deleteMetadata];
}
