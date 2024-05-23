import 'package:database_repository/database_repository.dart';
import 'package:flutter/material.dart';
import 'package:game_launcher/src/shared/view/conditional_parent_widget.dart';

class DevelopersListWidget extends StatelessWidget {
  final List<DeveloperModel> developers;
  const DevelopersListWidget({
    super.key,
    required this.developers,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> devs = [];
    for (int i = 0; i < developers.length; i++) {
      DeveloperModel dev = developers[i];
      devs.add(
        ConditionalParentWidget(
          condition: dev.website != null,
          child: Text(
            dev.name,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          conditionalBuilder: (child) => InkWell(
            // TODO
            /*onTap: () => showDialog(
              context: context,
              builder: (context) => ExternalLinkAlertDialog(
                externalLink: dev.website!,
              ),
            ),*/
            child: child,
          ),
        ),
      );
      if (i < developers.length - 1) {
        // Not last -> add separator and padding
        devs.addAll([
          const Text(","),
          const SizedBox(width: 2.0),
        ]);
      }
    }
    // Add empty text widget in order to reserve space
    if (devs.isEmpty) {
      devs.add(Text(
        "",
        style: Theme.of(context).textTheme.labelMedium,
      ));
    }
    return Row(
      children: devs,
    );
  }
}
