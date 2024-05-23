import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_launcher/src/game/details/images_tab/image_picker/cubit/image_picker_cubit.dart';

// TODO decide where to move
const List<String> supportedImageExtensions = ["png", "jpg", "jpeg", "gif"];

class ImagePickerWidget extends StatelessWidget {
  final String? initialDirectory;
  final List<String>? initialImages;
  final void Function(List<String> imagePaths) onChanged;
  final bool multiSelection;
  final double? width;
  final double? height;

  const ImagePickerWidget({
    super.key,
    this.initialDirectory,
    this.initialImages,
    required this.onChanged,
    this.width,
    this.height,
  }) : multiSelection = false;

  const ImagePickerWidget.multiSelection({
    super.key,
    this.initialDirectory,
    this.initialImages,
    required this.onChanged,
    this.width,
    this.height,
  }) : multiSelection = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ImagePickerCubit(initialImages: initialImages ?? []),
      child: _ImagePickerContent(
        initialDirectory: initialDirectory,
        initialImages: initialImages,
        onChanged: onChanged,
        width: width,
        height: height,
        multiSelection: multiSelection,
      ),
    );
  }
}

class _ImagePickerContent extends StatelessWidget {
  final String? initialDirectory;
  final List<String>? initialImages;
  final void Function(List<String> imagePaths) onChanged;
  final bool multiSelection;
  final double? width;
  final double? height;

  const _ImagePickerContent({
    super.key,
    this.initialDirectory,
    this.initialImages,
    required this.onChanged,
    this.width,
    this.height,
    required this.multiSelection,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DottedBorder(
        color: Theme.of(context).colorScheme.onBackground,
        dashPattern: const [8, 4],
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            FilePickerResult? result = await FilePicker.platform
                .pickFiles(
              initialDirectory: initialDirectory,
              allowedExtensions: supportedImageExtensions,
              type: FileType.custom,
              allowMultiple: multiSelection,
            )
                .catchError(
              (winError) {
                debugPrint("FilePicker error $winError");
                return null;
              },
            );
            if (result != null && context.mounted) {
              List<String> selectedImagePaths =
                  context.read<ImagePickerCubit>().state.selectedImagePaths;
              if (multiSelection) {
                Set<String> selectedImagesSet = Set.from(selectedImagePaths);
                selectedImagesSet.addAll(result.files.map((e) => e.path!));
                selectedImagePaths = selectedImagesSet.toList();
              } else {
                selectedImagePaths = result.files.map((e) => e.path!).toList();
              }
              context
                  .read<ImagePickerCubit>()
                  .setSelectedImagePaths(selectedImagePaths);
              onChanged(selectedImagePaths);
            }
          },
          child: BlocBuilder<ImagePickerCubit, ImagePickerState>(
            builder: (context, state) => state.selectedImagePaths.isNotEmpty
                ? _buildPreview(state.selectedImagePaths)
                : _buildSelection(),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(List<String> selectedImagePaths) {
    assert(selectedImagePaths.isNotEmpty);
    if (!multiSelection) {
      return Center(
        child: Image.file(
          File(selectedImagePaths[0]),
        ),
      );
    } else {
      return GridView.builder(
        itemCount: selectedImagePaths.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2.0,
          mainAxisSpacing: 2.0,
        ),
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black38),
                  ),
                  child: Image.file(
                    File(selectedImagePaths[index]),
                  ),
                ),
              ),
              Positioned(
                top: 0.0,
                right: 0.0,
                child: IconButton(
                  onPressed: () {
                    final images = [...selectedImagePaths];
                    images.removeAt(index);
                    context
                        .read<ImagePickerCubit>()
                        .setSelectedImagePaths(images);
                  },
                  splashRadius: 20.0,
                  icon: const Icon(Icons.close),
                ),
              )
            ],
          );
        },
      );
    }
  }

  Widget _buildSelection() {
    return const Center(
      child: Icon(
        Icons.add_circle,
      ),
    );
  }
}
