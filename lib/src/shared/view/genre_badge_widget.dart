import 'package:database_repository/database_repository.dart';
import 'package:flutter/material.dart';

class GenreBadgeWidget extends StatelessWidget {
  final GenreModel genre;
  final bool selected;
  final Function()? onSelected;
  final bool small;
  const GenreBadgeWidget({
    super.key,
    required this.genre,
    required this.selected,
    this.onSelected,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget chip = Chip(
      padding: EdgeInsets.all(small ? 0.0 : 4.0),
      labelPadding: EdgeInsets.symmetric(horizontal: small ? 2.0 : 4.0),
      label: Text(
        genre.name,
        style: small
            ? Theme.of(context).textTheme.bodySmall
            : Theme.of(context).textTheme.bodyText2,
      ),
      backgroundColor: selected
          ? Theme.of(context).chipTheme.selectedColor
          : Theme.of(context).chipTheme.disabledColor,
    );
    Widget widget = onSelected != null
        ? GestureDetector(
            onTap: onSelected,
            child: chip,
          )
        : chip;
    if (genre.description != null) {
      return Tooltip(
        message: genre.description,
        child: widget,
      );
    }
    return widget;
  }
}
