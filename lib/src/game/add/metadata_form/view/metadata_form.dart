import 'package:database_repository/database_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:game_launcher/src/game/add/cubit/add_cubit.dart';
import 'package:game_launcher/src/game/add/metadata_form/bloc/metadata_form_bloc.dart';

class MetadataForm extends StatelessWidget {
  const MetadataForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MetadataFormBloc(
        gameDatabaseRepository: context.read<GameDatabaseRepository>(),
        gameEngineRepository: context.read<GameEngineRepository>(),
      ),
      child: const _MetadataFormContent(),
    );
  }
}

class _MetadataFormContent extends StatelessWidget {
  const _MetadataFormContent({super.key});

  final double _height = 48.0;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MetadataFormBloc, MetadataFormState>(
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 5.0),
            SizedBox(
              height: _height,
              child: _EngineInput(),
            ),
            const SizedBox(height: 5.0),
            SizedBox(
              height: _height,
              child: _ExePathInput(),
            ),
            const SizedBox(height: 5.0),
            SizedBox(
              height: _height,
              child: _SavePathInput(),
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
  }
}

const _contentPadding = EdgeInsets.symmetric(
  horizontal: 5.0,
  vertical: 2.0,
);

class _EngineInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetadataFormBloc, MetadataFormState>(
      buildWhen: (previous, current) => previous.engine != current.engine,
      builder: (context, state) {
        return DropdownButtonFormField<GameEngineModel>(
          value: state.engine.value,
          items: state.gameEngines
              .map((engine) => DropdownMenuItem(
                    value: engine,
                    child: Text(engine.displayName),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              context
                  .read<MetadataFormBloc>()
                  .add(EngineChanged(engine: value));
            }
          },
          decoration: const InputDecoration(
            labelText: "Engine",
            contentPadding: _contentPadding,
          ),
        );
      },
    );
  }
}

class _ExePathInput extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MetadataFormBloc, MetadataFormState>(
      listenWhen: (previous, current) =>
          previous.exePath != current.exePath ||
          current.exePath.value != _controller.text,
      listener: (context, state) {
        _controller.text = state.exePath.value ?? "";
        print("_ExePathInput listener ${_controller.text}");
      },
      buildWhen: (previous, current) =>
          previous.exePath != current.exePath ||
          previous.engine != current.engine,
      builder: (context, state) {
        return TextField(
          enabled: state.engine.isValid,
          onChanged: (value) => context
              .read<MetadataFormBloc>()
              .add(ExePathChanged(exePath: value)),
          controller: _controller,
          decoration: InputDecoration(
            labelText: "Executable location",
            contentPadding: _contentPadding,
            errorText: state.exePath.isValid
                ? null
                : state.exePath.displayError?.message,
          ),
        );
      },
    );
  }
}

class _SavePathInput extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MetadataFormBloc, MetadataFormState>(
      listenWhen: (previous, current) =>
          previous.savePath != current.savePath ||
          current.savePath.value != _controller.text,
      listener: (context, state) {
        _controller.text = state.savePath.value ?? "";
        print("_SavePathInput listener ${_controller.text}");
      },
      buildWhen: (previous, current) =>
          previous.savePath != current.savePath ||
          previous.engine != current.engine,
      builder: (context, state) {
        return TextField(
          enabled: state.engine.isValid,
          onChanged: (value) => context
              .read<MetadataFormBloc>()
              .add(SavePathChanged(savePath: value)),
          controller: _controller,
          decoration: const InputDecoration(
            labelText: "Saves location",
            contentPadding: _contentPadding,
          ),
        );
      },
    );
  }
}

class _CancelButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MetadataFormBloc, MetadataFormState>(
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
    return BlocConsumer<MetadataFormBloc, MetadataFormState>(
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
                    ? () =>
                        context.read<MetadataFormBloc>().add(FormSubmitted())
                    : null,
                child: const Text('Next'),
              );
      },
    );
  }
}
