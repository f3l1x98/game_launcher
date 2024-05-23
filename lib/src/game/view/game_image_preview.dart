import 'dart:io';

import 'package:flutter/material.dart';

class GameImagePreview extends StatefulWidget {
  final List<File> images;
  final int initialIndex;
  const GameImagePreview({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<GameImagePreview> createState() => _GameImagePreviewState();
}

class _GameImagePreviewState extends State<GameImagePreview> {
  late int index;

  @override
  void initState() {
    super.initState();
    index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    // TODO exclude Scaffold?!?!?
    return Container(
      color: Colors.black54,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            Positioned.fill(
              child: Hero(
                tag: "image-$index",
                // No filterQuality: FilterQuality.high, because image is big enough that this is not necessary
                child: Image.file(widget.images[index]),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  children: [
                    if (index > 0)
                      Material(
                        type: MaterialType.transparency,
                        child: Center(
                          child: IconButton(
                            onPressed: () => setState(() {
                              index--;
                            }),
                            padding: const EdgeInsets.all(0.0),
                            splashRadius: 20.0,
                            //hoverColor: Colors.red,
                            icon: const Icon(Icons.arrow_back_ios),
                          ),
                        ),
                      ),
                    Expanded(child: Container()),
                    if (index < widget.images.length - 1)
                      Material(
                        type: MaterialType.transparency,
                        child: Center(
                          child: IconButton(
                            onPressed: () => setState(() {
                              index++;
                            }),
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
        ),
      ),
    );
  }
}
