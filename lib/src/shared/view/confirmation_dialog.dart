import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final Widget content;

  const ConfirmationDialog({super.key, required this.content});
  const ConfirmationDialog.leavePage({super.key})
      : content = const Text("All data will be lost!");

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Are you sure?"),
      content: content,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("No"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text("Yes"),
        ),
      ],
    );
  }
}
