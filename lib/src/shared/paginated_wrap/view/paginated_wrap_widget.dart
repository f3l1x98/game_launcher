import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_launcher/src/shared/paginated_wrap/cubit/paginated_wrap_cubit.dart';

// TODO perhaps refactor such that it does not have all items but always the currentPageItems

class PaginatedWrap extends StatelessWidget {
  const PaginatedWrap({
    super.key,
    this.initialPage = 0,
    this.items = const [],
    this.onPageChanged,
  });

  final int initialPage;
  final List<Widget> items;
  final Function(int newPageNr)? onPageChanged;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaginatedWrapCubit(
        initialPage: initialPage,
        onPageChanged: onPageChanged,
      ),
      child: _PaginatedWrapContent(items: items),
    );
  }
}

class _PaginatedWrapContent extends StatelessWidget {
  static const int _itemsPerPage = 16;
  final List<Widget> items;

  const _PaginatedWrapContent({super.key, required this.items});

  int get maxPageNr => (max(0, items.length - 1) / _itemsPerPage).truncate();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // top pagination control
        _buildPaginationControls(),
        const SizedBox(height: 5.0),
        // Content
        BlocBuilder<PaginatedWrapCubit, PaginatedWrapState>(
          builder: (context, state) {
            return Wrap(
              children: getCurrentPageItems(state),
            );
          },
        ),
        const SizedBox(height: 5.0),
        // bottom pagination control
        _buildPaginationControls(),
      ],
    );
  }

  Widget _buildPaginationControls() {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        width: constraints.maxWidth,
        child: BlocBuilder<PaginatedWrapCubit, PaginatedWrapState>(
          buildWhen: (previous, current) =>
              previous.currentPage != current.currentPage,
          builder: (context, state) {
            return Wrap(
              alignment: WrapAlignment.center,
              spacing: 5.0,
              children: [
                // Arrow btn for previous page (disabled if min page reached)
                _buildPageButton(
                  pageNr: state.currentPage - 1,
                  content: const Icon(Icons.arrow_back_ios_sharp),
                ),
                // Button for navigating directly to first page (if displaying ...)
                if (state.currentPage - 3 >= 0)
                  _buildPageButton(
                    pageNr: 0,
                  ),
                // Icon inidicating that there are more pages, IF there are more than 2 pages before active one
                if (state.currentPage - 4 >= 0)
                  Text(
                    "...",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                // Page btn for previous 2 pages (IF POSSIBLE, aka if active page is 2, then only one btn for page 1)
                if (state.currentPage - 2 >= 0)
                  _buildPageButton(
                    pageNr: state.currentPage - 2,
                  ),
                if (state.currentPage - 1 >= 0)
                  _buildPageButton(
                    pageNr: state.currentPage - 1,
                  ),
                // Page btn for current page (marked as active and not clickable)
                _buildPageButton(
                  pageNr: state.currentPage,
                ),
                // Page btn for next 2 pages (IF POSSIBLE, aka if active page is 2, and maxPageNr is 3 -> only one for page 3)
                if (state.currentPage + 1 <= maxPageNr)
                  _buildPageButton(
                    pageNr: state.currentPage + 1,
                  ),
                if (state.currentPage + 2 <= maxPageNr)
                  _buildPageButton(
                    pageNr: state.currentPage + 2,
                  ),
                // Icon inidicating that there are more pages, IF there are more than 2 pages after active one
                if (state.currentPage + 4 <= maxPageNr)
                  Text(
                    "...",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                // Button for navigating directly to last page (if displaying ...)
                if (state.currentPage + 3 <= maxPageNr)
                  _buildPageButton(
                    pageNr: maxPageNr,
                  ),
                // Arrow btn for next page (disabled if max page reached)
                _buildPageButton(
                  pageNr: state.currentPage + 1,
                  content: const Icon(Icons.arrow_forward_ios_sharp),
                ),
              ],
            );
          },
        ),
      );
    });
  }

  Widget _buildPageButton({required int pageNr, Widget? content}) {
    return BlocBuilder<PaginatedWrapCubit, PaginatedWrapState>(
      buildWhen: (previous, current) =>
          previous.currentPage != current.currentPage,
      builder: (context, state) {
        return ElevatedButton(
          // deactivate button if outside range or if active page
          onPressed:
              pageNr < 0 || pageNr > maxPageNr || pageNr == state.currentPage
                  ? null
                  : () {
                      context.read<PaginatedWrapCubit>().changePage(pageNr);
                    },
          child: content ?? Text("${pageNr + 1}"),
        );
      },
    );
  }

  List<Widget> getCurrentPageItems(PaginatedWrapState state) {
    if (items.isEmpty) return [];
    int start = state.currentPage * _itemsPerPage;
    int? end = start + _itemsPerPage;
    // Unset end if it exceeds list length -> start until end of list
    if (end >= items.length) {
      end = null;
    }
    return items.sublist(start, end);
  }
}
