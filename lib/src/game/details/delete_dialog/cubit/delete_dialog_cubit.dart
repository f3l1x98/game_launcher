import 'package:bloc/bloc.dart';
import 'package:database_repository/database_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:files_repository/files_repository.dart';
import 'package:game_launcher/src/game/details/delete_dialog/models/delete_archive.dart';
import 'package:game_launcher/src/game/details/delete_dialog/models/delete_metadata.dart';
import 'package:path/path.dart' as p;

part 'delete_dialog_state.dart';

class DeleteDialogCubit extends Cubit<DeleteDialogState> {
  DeleteDialogCubit({
    required GameModel game,
    required GameDatabaseRepository gameDatabaseRepository,
    required FilesRepository filesRepository,
  })  : _game = game,
        _gameDatabaseRepository = gameDatabaseRepository,
        _filesRepository = filesRepository,
        super(const DeleteDialogState());

  final GameModel _game;
  final GameDatabaseRepository _gameDatabaseRepository;
  final FilesRepository _filesRepository;

  updateDeleteArchive({required bool newValue}) {
    final deleteArchive = DeleteArchive.dirty(newValue);
    emit(state.copyWith(deleteArchive: deleteArchive));
  }

  updateDeleteMetadata({required bool newValue}) {
    final deleteMetadata = DeleteMetadata.dirty(newValue);
    emit(state.copyWith(deleteMetadata: deleteMetadata));
  }

  Future<void> deleteGame() async {
    // Delete archive
    if (state.deleteArchive.value) {
      await _filesRepository
          .getFile(p.join(
            _filesRepository.gamesUninstalledPath,
            _game.archiveFileName,
          ))
          .delete();
    }

    // Delete metadata
    if (state.deleteMetadata.value) {
      await _filesRepository
          .getDirectory(_game.metadataPath)
          .delete(recursive: true);
    }

    // Delete from DB
    await _gameDatabaseRepository.delete(_game);
  }
}
