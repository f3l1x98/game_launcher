import 'dart:io';

import 'package:database_repository/database_repository.dart';
import 'package:files_repository/files_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_launcher/src/game/details/bloc/details_bloc.dart';
import 'package:game_launcher/src/game/details/images_tab/image_preview/view/image_preview.dart';
import 'package:game_launcher/src/game/details/images_tab/view/image_add_dialog.dart';
import 'package:native_context_menu/native_context_menu.dart';
import 'package:path/path.dart' as p;

class ImagesTabWidget extends StatelessWidget {
  final GameModel game;

  const ImagesTabWidget({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // TODO allow adding new images -> USE ImagePickerWidget.multiSelection WITH INITIAL VALUES
    final filesRepository = context.read<FilesRepository>();

    if (game.images.isNotEmpty) {
      List<File> imageFiles = game.images
          .map((file) =>
              filesRepository.getFile(p.join(game.metadataPath, file)))
          .toList();
      return GridView.builder(
        itemCount: imageFiles.length + 1,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
          //childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          if (index == imageFiles.length) {
            return IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ImageAddDialog(game: game),
                );
                throw UnimplementedError();
              },
              icon: const Icon(Icons.add),
            );
          } else {
            return ContextMenuRegion(
              onItemSelected: (item) {
                final File image = item.action as File;
                game.images.remove(p.basename(image.path));
                // TODO unsure if game.copyWith is necessary
                context.read<DetailsBloc>().add(DetailsUpdateGame(game: game));
              },
              menuItems: [
                MenuItem(
                  title: 'Delete',
                  action: imageFiles[index],
                ),
              ],
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (BuildContext context, _, __) {
                        return ImagePreview(
                          images: imageFiles,
                          initialIndex: index,
                        );
                      },
                    ),
                  );
                },
                child: Hero(
                  tag: "image-$index",
                  child: Image.file(
                    imageFiles[index],
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            );
          }
        },
      );
    } else {
      return const Center(child: Text("No Images."));
    }
  }
}
