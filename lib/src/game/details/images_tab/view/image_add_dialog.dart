import 'package:database_repository/database_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_launcher/src/game/details/images_tab/image_picker/view/image_picker_widget.dart';

class ImageAddDialog extends StatelessWidget {
  final GameModel game;

  ImageAddDialog({
    super.key,
    required this.game,
  });

  // TODO does this justify a cubit?!?!?
  String? image;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        constraints: const BoxConstraints(
          maxWidth: 800.0,
          maxHeight: 500.0,
        ),
        child: Column(
          children: [
            Expanded(
              child: ImagePickerWidget(
                onChanged: (imagePaths) {
                  if (imagePaths.isNotEmpty) image = imagePaths[0];
                },
              ),
            ),
            const SizedBox(height: 15.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 10.0),
                ElevatedButton(
                  onPressed: () async {
                    if (image != null) {
                      // TODO THIS IMAGE IS TO BE COPIED AND THE COPIED ONE SHOULD BE ADDED, NOT THIS ONE!!!!!!!!!
                      // Copy new images
                      /*List<File> copiedImages =
                              await GameService.get()
                                  .copyImagesToMetadata(
                            images: [image!],
                            gameMetadataPath: game.metadataPath,
                          );
                          game.images.addAll(copiedImages
                              .map((file) => p.basename(file.path)));*/
                      game.images.add(image!);
                      context.read<GameDatabaseRepository>().update(game);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add Image'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
