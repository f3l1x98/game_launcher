import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class StyledMultiSelectDialogField<T> extends StatelessWidget {
  final String? dropdownHint;
  final String dialogTitle;
  final List<MultiSelectItem<T>> items;
  final Function(List<T>) onConfirm;
  final String searchHint;
  final List<T> initialValue;
  final bool scroll;

  const StyledMultiSelectDialogField({
    super.key,
    this.dropdownHint,
    required this.dialogTitle,
    required this.items,
    required this.onConfirm,
    required this.searchHint,
    this.initialValue = const [],
    this.scroll = false,
  });

  @override
  Widget build(BuildContext context) {
    return MultiSelectDialogField<T>(
      listType: MultiSelectListType.CHIP,
      searchable: true,
      searchHint: searchHint,
      items: items,
      initialValue: initialValue,
      onConfirm: onConfirm,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
              width: 2.0,
              color: Theme.of(context).dividerColor //Colors.grey.shade700,
              ),
        ),
      ),
      chipDisplay: MultiSelectChipDisplay(
        height: 35.0,
        scroll: scroll,
      ),
      selectedColor: Theme.of(context).colorScheme.primary,
      selectedItemsTextStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      buttonIcon: const Icon(Icons.arrow_drop_down_sharp),
      buttonText: dropdownHint != null
          ? Text(
              dropdownHint!,
              style: TextStyle(color: Colors.grey.shade400),
            )
          : null,
      title: Text(dialogTitle),
    );
  }
}
