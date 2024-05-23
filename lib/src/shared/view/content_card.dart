import 'package:flutter/material.dart';

class ContentCard extends StatelessWidget {
  final Widget child;
  const ContentCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.onBackground,
          width: 0.1,
        ),
      ),
      padding: const EdgeInsets.all(5.0),
      child: child,
    );
  }
}
