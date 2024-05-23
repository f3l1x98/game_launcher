import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_launcher/src/game/details/images_tab/image_preview/cubit/image_preview_cubit.dart';

class ImagePreview extends StatelessWidget {
  final List<File> images;
  final int initialIndex;

  const ImagePreview({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ImagePreviewCubit(
        initialIndex: initialIndex,
        images: images,
      ),
      child: const _ImagePreviewContent(),
    );
  }
}

class _ImagePreviewContent extends StatelessWidget {
  const _ImagePreviewContent({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO exclude Scaffold?!?!?
    return Container(
      color: Colors.black54,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: BlocBuilder<ImagePreviewCubit, ImagePreviewState>(
          buildWhen: (previous, current) => previous.index != current.index,
          builder: (context, state) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Hero(
                    tag: "image-${state.index}",
                    // No filterQuality: FilterQuality.high, because image is big enough that this is not necessary
                    child: Image.file(state.getCurrentImageFile()),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Row(
                      children: [
                        if (state.index > 0)
                          Material(
                            type: MaterialType.transparency,
                            child: Center(
                              child: IconButton(
                                onPressed: () => context
                                    .read<ImagePreviewCubit>()
                                    .decrementIndex(),
                                padding: const EdgeInsets.all(0.0),
                                splashRadius: 20.0,
                                //hoverColor: Colors.red,
                                icon: const Icon(Icons.arrow_back_ios),
                              ),
                            ),
                          ),
                        Expanded(child: Container()),
                        if (state.index < state.images.length - 1)
                          Material(
                            type: MaterialType.transparency,
                            child: Center(
                              child: IconButton(
                                onPressed: () => context
                                    .read<ImagePreviewCubit>()
                                    .incrementIndex(),
                                padding: const EdgeInsets.all(0.0),
                                splashRadius: 20.0,
                                //hoverColor: Colors.red,
                                icon: const Icon(Icons.arrow_forward_ios),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
