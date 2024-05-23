import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_launcher/src/dashboard/section/cubit/section_cubit.dart';
import 'package:game_launcher/src/dashboard/section/view/scroll_button.dart';
import 'package:game_launcher/src/shared/view/content_card.dart';

class SectionWidget extends StatelessWidget {
  final String header;
  final bool scrollable;
  final List<Widget> content;

  const SectionWidget({
    super.key,
    required this.header,
    this.scrollable = false,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SectionCubit>(
      create: (context) => SectionCubit(),
      child: _SectionWidgetContent(
        header: header,
        scrollable: scrollable,
        content: content,
      ),
    );
  }
}

class _SectionWidgetContent extends StatefulWidget {
  final String header;
  final bool scrollable;
  final List<Widget> content;

  const _SectionWidgetContent({
    super.key,
    required this.header,
    this.scrollable = false,
    required this.content,
  });

  @override
  State<_SectionWidgetContent> createState() => _SectionWidgetContentState();
}

class _SectionWidgetContentState extends State<_SectionWidgetContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(updateButtonsEnabled);
    // Initial enabled check due to listener not triggering with init state
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      updateButtonsEnabled();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(updateButtonsEnabled);
    super.dispose();
  }

  updateButtonsEnabled() {
    final prevEnabled =
        _scrollController.hasClients && _scrollController.offset > 0.0;
    final nextEnabled = _scrollController.hasClients &&
        (_scrollController.offset == 0.0 || !_scrollController.position.atEdge);
    // TODO unsure if that triggers too many updates (depends on how efficient bloc is at detecting unnecessary updates)
    context.read<SectionCubit>().setPrevButtonEnabled(prevEnabled);
    context.read<SectionCubit>().setNextButtonEnabled(nextEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return ContentCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section header
          Text(
            widget.header,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 10.0),
          // Section content
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (widget.scrollable) {
      return Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.content,
            ),
          ),
          if (widget.content.isNotEmpty)
            Positioned.fill(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BlocBuilder<SectionCubit, SectionState>(
                    buildWhen: (previous, current) =>
                        previous.prevButtonEnabled != current.prevButtonEnabled,
                    builder: (context, state) => ScrollButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: state.prevButtonEnabled
                          ? () {
                              _scrollController.animateTo(
                                _scrollController.offset - 200.0,
                                duration: const Duration(milliseconds: 10),
                                curve: Curves.linear,
                              );
                            }
                          : null,
                    ),
                  ),
                  BlocBuilder<SectionCubit, SectionState>(
                    buildWhen: (previous, current) =>
                        previous.nextButtonEnabled != current.nextButtonEnabled,
                    builder: (context, state) => ScrollButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: state.nextButtonEnabled
                          ? () {
                              _scrollController.animateTo(
                                _scrollController.offset + 200.0,
                                duration: const Duration(milliseconds: 10),
                                curve: Curves.linear,
                              );
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    } else {
      return Row(
        children: widget.content,
      );
    }
  }
}
