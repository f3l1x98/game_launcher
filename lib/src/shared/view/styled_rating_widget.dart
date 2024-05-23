import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class StyledRatingWidget extends RatingWidget {
  StyledRatingWidget(BuildContext context)
      : super(
          full: Icon(
            Icons.star,
            color: Theme.of(context).colorScheme.primary,
          ),
          half: Icon(
            Icons.star_half_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          empty: Icon(
            Icons.star_outline,
            color: Theme.of(context).colorScheme.secondary,
          ),
        );
}
