import 'package:database_repository/database_repository.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:formz/formz.dart';
import 'package:game_launcher/src/game/add/cubit/add_cubit.dart';
import 'package:game_launcher/src/game/add/details_form/bloc/details_form_bloc.dart';
import 'package:game_launcher/src/shared/exceptions/unhandled_state_exception.dart';

class DetailsForm extends StatelessWidget {
  const DetailsForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DetailsFormBloc(
        gameDatabaseRepository: context.read<GameDatabaseRepository>(),
        genreDatabaseRepository: context.read<GenreDatabaseRepository>(),
        developerDatabaseRepository:
            context.read<DeveloperDatabaseRepository>(),
      ),
      child: const _DetailsFormContent(),
    );
  }
}

class _DetailsFormContent extends StatelessWidget {
  const _DetailsFormContent({super.key});

  final double _padding = 5.0;
  final double _height = 48.0;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DetailsFormBloc, DetailsFormState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status.isFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Something went wrong!')),
            );
        }
      },
      buildWhen: (previous, current) =>
          previous.runtimeType != current.runtimeType,
      builder: (context, state) {
        if (state is DetailsFormInitial) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is DetailsFormLoaded) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final halfInputWidth = constraints.maxWidth / 2.0 - _padding;
              // TODO refactor content
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: _height,
                        width: halfInputWidth,
                        child: _NameInput(),
                      ),
                      SizedBox(
                        height: _height,
                        width: halfInputWidth,
                        child: _LanguageInput(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5.0),
                  SizedBox(
                    height: _height * 1.5,
                    child: _DescriptionInput(),
                  ),
                  const SizedBox(height: 5.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: _height,
                        width: halfInputWidth,
                        child: _VotingInput(),
                      ),
                      SizedBox(
                        height: _height,
                        width: halfInputWidth,
                        child: _VersionInput(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: _height,
                        width: halfInputWidth,
                        child: _GenresInput(),
                      ),
                      SizedBox(
                        height: _height,
                        width: halfInputWidth,
                        child: _DevelopersInput(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: _height,
                        width: halfInputWidth,
                        child: _PrequelInput(),
                      ),
                      SizedBox(
                        height: _height,
                        width: halfInputWidth,
                        child: _SequelInput(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: _height,
                        width: halfInputWidth,
                        child: _WebsiteInput(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CancelButton(),
                      const SizedBox(width: 5.0),
                      _SubmitButton(),
                    ],
                  ),
                ],
              );
            },
          );
        } else {
          throw UnhandledStateException(state: state.runtimeType);
        }
      },
    );
  }
}

const _contentPadding = EdgeInsets.symmetric(
  horizontal: 5.0,
  vertical: 2.0,
);

class _NameInput extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DetailsFormBloc, DetailsFormState>(
      listenWhen: (previous, current) =>
          previous.name != current.name ||
          current.name.value != _controller.text,
      listener: (context, state) {
        _controller.text = state.name.value ?? "";
      },
      buildWhen: (previous, current) => previous.name != current.name,
      builder: (context, state) {
        return TextField(
          onChanged: (value) =>
              context.read<DetailsFormBloc>().add(NameChanged(name: value)),
          controller: _controller,
          decoration: InputDecoration(
            labelText: "Name",
            contentPadding: _contentPadding,
            errorText:
                state.name.isValid ? null : state.name.displayError?.message,
          ),
        );
      },
    );
  }
}

class _LanguageInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO old was completely different
    return BlocBuilder<DetailsFormBloc, DetailsFormState>(
      buildWhen: (previous, current) => previous.language != current.language,
      builder: (context, state) {
        return DropdownButtonFormField<LanguageEnum>(
          value: state.language.value,
          items: LanguageEnum.values
              .map((language) => DropdownMenuItem(
                    value: language,
                    child: Text(language.displayName),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              context
                  .read<DetailsFormBloc>()
                  .add(LanguageChanged(language: value));
            }
          },
          decoration: const InputDecoration(
            labelText: "Language",
            contentPadding: _contentPadding,
          ),
        );
      },
    );
  }
}

class _DescriptionInput extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DetailsFormBloc, DetailsFormState>(
      listenWhen: (previous, current) =>
          previous.description != current.description ||
          current.description.value != _controller.text,
      listener: (context, state) {
        _controller.text = state.description.value ?? "";
      },
      buildWhen: (previous, current) =>
          previous.description != current.description,
      builder: (context, state) {
        return TextField(
          onChanged: (value) => context
              .read<DetailsFormBloc>()
              .add(DescriptionChanged(description: value)),
          controller: _controller,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          expands: true,
          decoration: const InputDecoration(
            labelText: "Description",
            alignLabelWithHint: true,
            floatingLabelAlignment: FloatingLabelAlignment.start,
            contentPadding: _contentPadding,
          ),
        );
      },
    );
  }
}

class _VotingInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailsFormBloc, DetailsFormState>(
      buildWhen: (previous, current) => previous.voting != current.voting,
      builder: (context, state) {
        return InputDecorator(
          decoration: const InputDecoration(
            labelText: "Voting",
            border: InputBorder.none,
            contentPadding: _contentPadding,
          ),
          child: RatingBar(
            initialRating: state.voting.value.toDouble(),
            glow: false,
            itemSize: 30.0,
            ratingWidget: RatingWidget(
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
            ),
            onRatingUpdate: (value) => context
                .read<DetailsFormBloc>()
                .add(VotingChanged(voting: value.toInt())),
          ),
        );
      },
    );
  }
}

class _VersionInput extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DetailsFormBloc, DetailsFormState>(
      listenWhen: (previous, current) =>
          previous.version != current.version ||
          current.version.value != _controller.text,
      listener: (context, state) {
        _controller.text = state.version.value ?? "";
      },
      buildWhen: (previous, current) => previous.version != current.version,
      builder: (context, state) {
        return TextField(
          onChanged: (value) => context
              .read<DetailsFormBloc>()
              .add(VersionChanged(version: value)),
          controller: _controller,
          decoration: InputDecoration(
            labelText: "Version",
            contentPadding: _contentPadding,
            errorText: state.version.isValid
                ? null
                : state.version.displayError?.message,
          ),
        );
      },
    );
  }
}

class _GenresInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailsFormBloc, DetailsFormState>(
      buildWhen: (previous, current) => previous.genres != current.genres,
      builder: (context, state) {
        // TODO perhaps use DropdownSearch<String>.multiSelection for consistency
        /*return StyledMultiSelectDialogField<GenreModel>(
          dropdownHint: "Select genres",
          dialogTitle: "Select genres",
          searchHint: "Genre",
          initialValue: state.genres.value,
          scroll: true,
          items: (state as DetailsFormLoaded)
              .genreModels
              .map((genre) => MultiSelectItem(genre, genre.name))
              .toList(),
          onConfirm: (value) =>
              context.read<DetailsFormBloc>().add(GenresChanged(genres: value)),
        );*/

        return DropdownSearch<GenreModel>.multiSelection(
          compareFn: (item1, item2) => item1 == item2,
          itemAsString: (item) => item.name,
          items: (state as DetailsFormLoaded).genreModels,
          selectedItems: state.genres.value,
          onChanged: (value) =>
              context.read<DetailsFormBloc>().add(GenresChanged(genres: value)),
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
              hintText: "Select genres",
              contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
            ),
            textAlignVertical: TextAlignVertical.center,
          ),
        );
      },
    );
  }
}

class _DevelopersInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailsFormBloc, DetailsFormState>(
      buildWhen: (previous, current) =>
          previous.developers != current.developers,
      builder: (context, state) {
        // TODO perhaps use DropdownSearch<String>.multiSelection for consistency
        /*return StyledMultiSelectDialogField<DeveloperModel>(
          dropdownHint: "Select developers",
          dialogTitle: "Select developers",
          searchHint: "Developer",
          initialValue: state.developers.value,
          scroll: true,
          items: (state as DetailsFormLoaded)
              .developerModels
              .map((developer) => MultiSelectItem(developer, developer.name))
              .toList(),
          onConfirm: (value) => context
              .read<DetailsFormBloc>()
              .add(DevelopersChanged(developers: value)),
        );*/
        return DropdownSearch<DeveloperModel>.multiSelection(
          compareFn: (item1, item2) => item1 == item2,
          itemAsString: (item) => item.name,
          items: (state as DetailsFormLoaded).developerModels,
          selectedItems: state.developers.value,
          onChanged: (value) => context
              .read<DetailsFormBloc>()
              .add(DevelopersChanged(developers: value)),
          popupProps: const PopupPropsMultiSelection.dialog(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: "Developer",
              ),
            ),
          ),
          dropdownDecoratorProps: const DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              hintText: "Select developers",
              contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
            ),
            textAlignVertical: TextAlignVertical.center,
          ),
        );
      },
    );
  }
}

// TODO sequel prequel are same input type but different input -> extract parent
class _PrequelInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailsFormBloc, DetailsFormState>(
      buildWhen: (previous, current) => previous.prequel != current.prequel,
      builder: (context, state) {
        return DropdownSearch<GameModel>(
          compareFn: (item1, item2) => item1 == item2,
          itemAsString: (item) => item.name,
          items: (state as DetailsFormLoaded).gameModels,
          selectedItem: state.prequel.value,
          onChanged: (value) => context
              .read<DetailsFormBloc>()
              .add(PrequelChanged(prequel: value)),
          popupProps: PopupProps.dialog(
            disabledItemFn: (item) => item == state.prequel.value,
            showSearchBox: true,
            searchFieldProps: const TextFieldProps(
              decoration: InputDecoration(
                hintText: "Prequel game",
              ),
            ),
          ),
          dropdownDecoratorProps: const DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              hintText: "Prequel game",
              contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
            ),
            textAlignVertical: TextAlignVertical.center,
          ),
        );
      },
    );
  }
}

class _SequelInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailsFormBloc, DetailsFormState>(
      buildWhen: (previous, current) => previous.sequel != current.sequel,
      builder: (context, state) {
        return DropdownSearch<GameModel>(
          compareFn: (item1, item2) => item1 == item2,
          itemAsString: (item) => item.name,
          items: (state as DetailsFormLoaded).gameModels,
          selectedItem: state.sequel.value,
          onChanged: (value) =>
              context.read<DetailsFormBloc>().add(SequelChanged(sequel: value)),
          popupProps: PopupProps.dialog(
            disabledItemFn: (item) => item == state.sequel.value,
            showSearchBox: true,
            searchFieldProps: const TextFieldProps(
              decoration: InputDecoration(
                hintText: "Sequel game",
              ),
            ),
          ),
          dropdownDecoratorProps: const DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              hintText: "Sequel game",
              contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
            ),
            textAlignVertical: TextAlignVertical.center,
          ),
        );
      },
    );
  }
}

class _WebsiteInput extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DetailsFormBloc, DetailsFormState>(
      listenWhen: (previous, current) =>
          previous.website != current.website ||
          current.website.value != _controller.text,
      listener: (context, state) {
        _controller.text = state.website.value ?? "";
      },
      buildWhen: (previous, current) => previous.website != current.website,
      builder: (context, state) {
        return TextField(
          onChanged: (value) => context
              .read<DetailsFormBloc>()
              .add(WebsiteChanged(website: value)),
          controller: _controller,
          decoration: InputDecoration(
            labelText: "Website",
            contentPadding: _contentPadding,
            errorText: state.website.isValid
                ? null
                : state.website.displayError?.message,
          ),
        );
      },
    );
  }
}

class _CancelButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailsFormBloc, DetailsFormState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isInProgress
            ? const SizedBox.shrink()
            : TextButton(
                onPressed: () => context.read<AddCubit>().stepCancelled(),
                child: const Text('Cancel'),
              );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DetailsFormBloc, DetailsFormState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status.isSuccess) {
          context.read<AddCubit>().stepContinued();
        }
      },
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isValid != current.isValid,
      builder: (context, state) {
        return state.status.isInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                style: ElevatedButton.styleFrom(elevation: 0),
                onPressed: state.isValid
                    ? () => context.read<DetailsFormBloc>().add(FormSubmitted())
                    : null,
                child: const Text('Next'),
              );
      },
    );
  }
}
