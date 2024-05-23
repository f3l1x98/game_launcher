import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_launcher/src/shared/progress_widget/cubit/progress_cubit.dart';
import 'package:progress_repository/progress_repository.dart';

class ProgressWidget extends StatelessWidget {
  final Widget? title;
  final TextStyle? descriptionStyle;
  final TextStyle? internalDescriptionStyle;
  final TextStyle? defaultTitleStyle;

  const ProgressWidget({
    super.key,
    this.title,
    this.descriptionStyle,
    this.internalDescriptionStyle,
    this.defaultTitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProgressCubit(
        progressRepository: context.read<ProgressRepository>(),
      ),
      child: _ProgressWidgetContent(
        title: title,
        descriptionStyle: descriptionStyle,
        internalDescriptionStyle: internalDescriptionStyle,
        defaultTitleStyle: defaultTitleStyle,
      ),
    );
  }
}

class _ProgressWidgetContent extends StatelessWidget {
  final Widget? title;
  final TextStyle? descriptionStyle;
  final TextStyle? internalDescriptionStyle;
  final TextStyle? defaultTitleStyle;

  const _ProgressWidgetContent({
    super.key,
    this.title,
    this.descriptionStyle,
    this.internalDescriptionStyle,
    this.defaultTitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgressCubit, ProgressState>(
      builder: (context, state) {
        if (!state.hasCurrentProgress) {
          return const Center(
            child: Text("No running progress!"),
          );
        }

        return state.currentProgresses.length == 1
            ? _buildSingleProgress(context, state.currentProgresses.first)
            : _buildMultipleProgress(context, state.currentProgresses);
      },
    );
  }

  Widget _buildSingleProgress(
    BuildContext context,
    Progress progressData,
  ) {
    final titleWidget = title ??
        (progressData.name != null
            ? Text(
                progressData.name ?? "Unknown Progress",
                style:
                    defaultTitleStyle ?? Theme.of(context).textTheme.bodyLarge,
              )
            : null);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (titleWidget != null) titleWidget,
        if (titleWidget != null) const SizedBox(height: 5.0),
        _buildProgressIndicator(context, progressData),
        if (progressData.childProgress != null)
          _buildProgressIndicator(
            context,
            progressData.childProgress!,
            isInternal: true,
          ),
      ],
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    Progress progress, {
    bool isInternal = false,
    bool useName = false,
  }) {
    if (progress.percentage == 1.0) {
      return const Text("Completed");
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LinearProgressIndicator(
          value: progress.max == 0 ? null : progress.percentage,
          minHeight: isInternal ? 5.0 : 8.0,
          semanticsLabel: "Current progress",
          semanticsValue: progress.percentage.toString(),
        ),
        // Current stage
        Text(
          (useName ? progress.name : progress.description) ?? "",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: isInternal
              ? internalDescriptionStyle ??
                  Theme.of(context).textTheme.bodyMedium
              : descriptionStyle ?? Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildMultipleProgress(
    BuildContext context,
    List<Progress> progressData,
  ) {
    const maxNumberDisplayedProgresses = 3;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Running ${progressData.length} progresses",
          style: defaultTitleStyle ?? Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 5.0),
        // TODO MAX SIZE (if more than 3 display first 3 and a more indicator)
        // TODO PERHAPS USE data.name INSTEAD OF data.currentDescription (could be better)
        ...progressData
            .getRange(0, min(maxNumberDisplayedProgresses, progressData.length))
            .map((data) => _buildProgressIndicator(
                  context,
                  data,
                  useName: true,
                )),
        if (progressData.length > maxNumberDisplayedProgresses)
          const Text("..."),
      ],
    );
  }
}
