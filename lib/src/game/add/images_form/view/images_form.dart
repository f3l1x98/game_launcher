import 'package:database_repository/database_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:game_launcher/src/game/add/cubit/add_cubit.dart';
import 'package:game_launcher/src/game/add/images_form/bloc/images_form_bloc.dart';
import 'package:game_launcher/src/shared/select_image/view/select_image.dart';

class ImagesForm extends StatelessWidget {
  const ImagesForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ImagesFormBloc(
        gameDatabaseRepository: context.read<GameDatabaseRepository>(),
      ),
      child: const _ImagesFormContent(),
    );
  }
}

class _ImagesFormContent extends StatelessWidget {
  const _ImagesFormContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ImagesFormBloc, ImagesFormState>(
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
        return LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 5.0),
                ElevatedButton.icon(
                  onPressed: () =>
                      context.read<ImagesFormBloc>().add(SelectFromDirectory()),
                  icon: const Icon(Icons.folder),
                  label: const Text("Select from folder"),
                ),
                const Divider(),
                /*const _CoverInput(),
            const _ImagesInput(),*/
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 256.0,
                      height: 330.0,
                      child: _CoverInput(),
                    ),
                    SizedBox(
                      width: constraints.maxWidth - 265,
                      height: 330.0,
                      child: _ImagesInput(),
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
      },
    );
  }
}

class _CoverInput extends StatelessWidget {
  const _CoverInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImagesFormBloc, ImagesFormState>(
      buildWhen: (previous, current) => previous.cover != current.cover,
      builder: (context, state) {
        return SelectImage(
          key: UniqueKey(),
          initialValue: state.cover.value != null ? [state.cover.value!] : [],
          allowedExtensions: supportedImageExtensions,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: "Cover",
            labelStyle: Theme.of(context).textTheme.headlineSmall,
          ),
          onChanged: (val) {
            if (val.isNotEmpty) {
              context.read<ImagesFormBloc>().add(CoverChanged(cover: val[0]));
            }
          },
        );
      },
    );
  }
}

class _ImagesInput extends StatelessWidget {
  const _ImagesInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImagesFormBloc, ImagesFormState>(
      buildWhen: (previous, current) => previous.images != current.images,
      builder: (context, state) {
        return SelectImage.multiSelection(
          key: UniqueKey(),
          initialValue: state.images.value,
          allowedExtensions: supportedImageExtensions,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: "Images",
            labelStyle: Theme.of(context).textTheme.headlineSmall,
          ),
          //height: 144.0,
          onChanged: (val) =>
              context.read<ImagesFormBloc>().add(ImagesChanged(images: val)),
        );
      },
    );
  }
}

class _CancelButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImagesFormBloc, ImagesFormState>(
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
    return BlocConsumer<ImagesFormBloc, ImagesFormState>(
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
                    ? () => context.read<ImagesFormBloc>().add(FormSubmitted())
                    : null,
                child: const Text('Next'),
              );
      },
    );
  }
}
