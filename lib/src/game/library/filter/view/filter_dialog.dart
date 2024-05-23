import 'package:database_repository/database_repository.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_launcher/src/game/library/filter/bloc/filter_bloc.dart';
import 'package:game_launcher/src/shared/exceptions/unhandled_state_exception.dart';

class FilterDialog extends StatelessWidget {
  const FilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        constraints: const BoxConstraints(
          maxWidth: 800.0,
          maxHeight: 500.0,
        ),
        child: BlocProvider<FilterBloc>(
          lazy: false,
          create: (context) => FilterBloc(
            gameDatabaseRepository: context.read<GameDatabaseRepository>(),
            genreDatabaseRepository: context.read<GenreDatabaseRepository>(),
          ),
          child: const _FilterDialogContent(),
        ),
      ),
    );
  }
}

class _FilterDialogContent extends StatelessWidget {
  static const double _padding = 5.0;

  const _FilterDialogContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SearchInput(),
        const SizedBox(height: 5.0),
        BlocBuilder<FilterBloc, FilterState>(
          buildWhen: (previous, current) =>
              previous.runtimeType != current.runtimeType,
          builder: (context, state) {
            if (state is FilterInitial) {
              return const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                ],
              );
            } else if (state is FilterLoaded) {
              return state.genres.isEmpty
                  ? Container()
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        double genreFilterWidth =
                            (constraints.maxWidth / 2) - _padding;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: genreFilterWidth,
                              child: const _IncludedGenresInput(),
                            ),
                            const SizedBox(width: _padding),
                            SizedBox(
                              width: genreFilterWidth,
                              child: const _ExcludedGenresInput(),
                            ),
                          ],
                        );
                      },
                    );
            } else {
              throw UnhandledStateException(state: state.runtimeType);
            }
          },
        ),
        const _InstalledOnlyInput(),
        // TODO LAYOUT, POSITION, STYLING (Label, ...), ...
        Align(
          alignment: Alignment.centerRight,
          child: BlocBuilder<FilterBloc, FilterState>(
            builder: (context, state) => ElevatedButton.icon(
              onPressed: state.isPure()
                  ? null
                  : () => context.read<FilterBloc>().add(FilterCleared()),
              label: const Text("Clear filter"),
              icon: const Icon(Icons.clear_all),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchInput extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();

  _SearchInput({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO debounce
    return BlocConsumer<FilterBloc, FilterState>(
      listenWhen: (previous, current) =>
          previous.searchText != current.searchText ||
          // Check _searchController.text due to previous == current in case first build
          // (either because previous cached from last time or just how it is implemented)
          current.searchText.value != _searchController.text,
      listener: (context, state) {
        _searchController.text = state.searchText.value;
      },
      buildWhen: (previous, current) =>
          previous.searchText != current.searchText,
      builder: (context, state) => TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: "Game name",
          contentPadding: EdgeInsets.symmetric(horizontal: 5.0),
        ),
        onSubmitted: (value) =>
            context.read<FilterBloc>().add(FilterSearchTextChanged(value)),
      ),
    );
  }
}

class _IncludedGenresInput extends StatelessWidget {
  const _IncludedGenresInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterBloc, FilterState>(
      // TODO this invalidates the internal state of StyledMultiSelectDialogField because it rebuilds it either way
      buildWhen: (previous, current) =>
          previous.includedGenres != current.includedGenres,
      builder: (context, state) {
        return DropdownSearch<GenreModel>.multiSelection(
          compareFn: (item1, item2) => item1 == item2,
          itemAsString: (item) => item.name,
          items: (state as FilterLoaded).genres,
          selectedItems: state.includedGenres.value,
          onChanged: (value) => context
              .read<FilterBloc>()
              .add(FilterIncludedGenresChanged(value)),
          popupProps: const PopupPropsMultiSelection.dialog(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: "Genre",
              ),
            ),
          ),
          dropdownDecoratorProps: const DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              hintText: "Select included genres",
              contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
            ),
            textAlignVertical: TextAlignVertical.center,
          ),
        );
      },
    );
  }
}

class _ExcludedGenresInput extends StatelessWidget {
  const _ExcludedGenresInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterBloc, FilterState>(
      // TODO this invalidates the internal state of StyledMultiSelectDialogField because it rebuilds it either way
      buildWhen: (previous, current) =>
          previous.excludedGenres != current.excludedGenres,
      builder: (context, state) {
        return DropdownSearch<GenreModel>.multiSelection(
          compareFn: (item1, item2) => item1 == item2,
          itemAsString: (item) => item.name,
          items: (state as FilterLoaded).genres,
          selectedItems: state.excludedGenres.value,
          onChanged: (value) => context
              .read<FilterBloc>()
              .add(FilterExcludedGenresChanged(value)),
          popupProps: const PopupPropsMultiSelection.dialog(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: "Genre",
              ),
            ),
          ),
          dropdownDecoratorProps: const DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              hintText: "Select excluded genres",
              contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
            ),
            textAlignVertical: TextAlignVertical.center,
          ),
        );
      },
    );
  }
}

class _InstalledOnlyInput extends StatelessWidget {
  const _InstalledOnlyInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterBloc, FilterState>(
      builder: (context, state) {
        return SwitchListTile(
          title: const Text("Installed only"),
          value: state.installedOnly.value,
          onChanged: (value) =>
              context.read<FilterBloc>().add(FilterInstalledOnlyChanged(value)),
        );
      },
    );
  }
}
