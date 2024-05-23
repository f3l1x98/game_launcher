import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final Function()? onTap;
  final IconData icon;
  final String name;
  const CardWidget({
    super.key,
    this.onTap,
    required this.icon,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Tooltip(
          message: name,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox.square(
              dimension: 64.0,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(icon, size: 32.0),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.bodyLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
