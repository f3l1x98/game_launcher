import 'package:database_repository/database_repository.dart';
import 'package:files_repository/files_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_launcher/src/game/details/configuration_tab/add_save_profile_dialog/cubit/add_save_profile_cubit.dart';

class AddSaveProfileDialog extends StatelessWidget {
  final GameModel game;
  final List<SaveProfileModel> saveProfiles;

  const AddSaveProfileDialog({
    super.key,
    required this.game,
    required this.saveProfiles,
  });

  @override
  Widget build(BuildContext context) {
    /*return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 200.0,
          child: Form(
            key: _formKey,
            child: _AddSaveProfileContent(),
          ),
        ),
      ),
    );*/
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        constraints: const BoxConstraints(
          maxWidth: 800.0,
          maxHeight: 500.0,
        ),
        child: BlocProvider(
          create: (context) => AddSaveProfileCubit(
            game: game,
            saveProfileNames: saveProfiles.map((e) => e.name).toList(),
            gameDatabaseRepository: context.read<GameDatabaseRepository>(),
            gameEngineRepository: context.read<GameEngineRepository>(),
            saveProfileRepository:
                context.read<SaveProfileDatabaseRepository>(),
            filesRepository: context.read<FilesRepository>(),
          ),
          child: const _AddSaveProfileContent(),
        ),
      ),
    );
  }
}

class _AddSaveProfileContent extends StatelessWidget {
  const _AddSaveProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "New save profile",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 5.0),
        // TODO DECIDE WHETHER TO USE formz, bloc, flutter_form_builder AND/OR reactive_forms
        //  -> Could use just flutter_form_builder
        //  -> https://bloclibrary.dev/tutorials/flutter-login/#login uses formz + bloc + textField -> DOES NOT USE FORMS
        //  -> SEE Filter FOR formz + bloc
        //  -> Could use reactive_forms and store the form inside a bloc (bloc not bloc state) -> separates business logic
        //    -> TODO Johann suggests formz (does not like accessing values using harcoded strings like reactive_forms and flutter_form_builder do)
        // TODO Strictly speaking this maintains its own state -> bloc unnecessary
        //  HOWEVER: bloc would serve to extract buisness logic for creating save profile into separate file
        /*FormBuilderTextField(
          name: 'profile_name',
          expands: false,
          decoration: const InputDecoration(
            isDense: true,
            hintText: "Profile name",
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(),
            (value) {
              if (saveProfiles.any((profile) => profile.name == value)) {
                return "Name already used!";
              }
              return null;
            }
          ]),
        ),*/
        _NameInput(),
        /*FormBuilderSwitch(
          name: 'copy_current',
          title: const Text("Copy current savefiles"),
          initialValue: false,
        ),*/
        const _CopyCurrentInput(),
        const SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                context.read<AddSaveProfileCubit>().createSaveProfile();
                // TODO old impl had provider.isLoading to disable this btn -> DO I STILL NEED THIS?!?!?!
                /*if (_formKey.currentState?.saveAndValidate() ?? false) {
                  _createSaveProfile(
                    context: context,
                    game: game,
                    name: _formKey.currentState?.value['profile_name'],
                    prefillWithCurrent:
                        _formKey.currentState?.value['copy_current'],
                  );
                  Navigator.of(context).pop();
                }*/
              },
              child: const Text("Add"),
            )
          ],
        )
      ],
    );
  }
}

const _contentPadding = EdgeInsets.symmetric(
  horizontal: 5.0,
  vertical: 2.0,
);

class _NameInput extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  _NameInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddSaveProfileCubit, AddSaveProfileState>(
      listenWhen: (previous, current) =>
          previous.saveProfileName != current.saveProfileName ||
          current.saveProfileName.value != _controller.text,
      listener: (context, state) {
        _controller.text = state.saveProfileName.value ?? "";
      },
      buildWhen: (previous, current) =>
          previous.saveProfileName != current.saveProfileName,
      builder: (context, state) {
        return TextField(
          onChanged: (value) => context
              .read<AddSaveProfileCubit>()
              .updateSaveProfileName(value: value),
          controller: _controller,
          decoration: InputDecoration(
            labelText: "Profile name",
            contentPadding: _contentPadding,
            errorText: state.saveProfileName.isValid
                ? null
                : state.saveProfileName.displayError?.message,
          ),
        );
      },
    );
  }
}

class _CopyCurrentInput extends StatelessWidget {
  const _CopyCurrentInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddSaveProfileCubit, AddSaveProfileState>(
      buildWhen: (previous, current) =>
          previous.copyCurrentSave != current.copyCurrentSave,
      builder: (context, state) {
        return SwitchListTile(
          title: const Text("Copy current savefiles"),
          contentPadding: _contentPadding,
          value: state.copyCurrentSave.value,
          onChanged: (value) => context
              .read<AddSaveProfileCubit>()
              .updateCopyCurrent(value: value),
        );
      },
    );
  }
}
