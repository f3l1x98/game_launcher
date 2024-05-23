import 'package:database_repository/database_repository.dart';
import 'package:files_repository/files_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GameCardWidget extends StatelessWidget {
  final Size size;
  final GameModel game;
  const GameCardWidget({
    super.key,
    required this.game,
    this.size = const Size(250, 380),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: size,
      child: GestureDetector(
        child: Opacity(
          opacity: game.installed ? 1 : .2,
          child: Card(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.file(
                    context
                        .read<FilesRepository>()
                        .getFile(game.coverPath ?? ""),
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset("assets/images/image_not_found.jpg"),
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 2.0,
                    ),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(5.0),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black,
                          Colors.black26,
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Tooltip(
                      message: game.name,
                      child: Text(
                        textAlign: TextAlign.center,
                        game.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          context.go('/games/${game.id}');
        },
      ),
    );
  }
}
