import 'package:database_repository/database_repository.dart';
import 'package:files_repository/files_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_launcher/src/game/add/cubit/add_cubit.dart';
import 'package:game_launcher/src/game/add/details_form/view/details_form.dart';
import 'package:game_launcher/src/game/add/images_form/view/images_form.dart';
import 'package:game_launcher/src/game/add/metadata_form/view/metadata_form.dart';
import 'package:game_launcher/src/shared/exceptions/unhandled_state_exception.dart';
import 'package:game_launcher/src/shared/view/confirmation_dialog.dart';
import 'package:game_launcher/src/shared/view/content_card.dart';
import 'package:go_router/go_router.dart';

class AddScreen extends StatelessWidget {
  final String archiveFilePath;

  const AddScreen({super.key, required this.archiveFilePath});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddCubit(
        archiveFilePath: archiveFilePath,
        archivesRepository: context.read<ArchivesRepository>(),
        filesRepository: context.read<FilesRepository>(),
        gameDatabaseRepository: context.read<GameDatabaseRepository>(),
        gameEngineRepository: context.read<GameEngineRepository>(),
      ),
      child: const _AddScreenContent(),
    );
  }
}

class _AddScreenContent extends StatelessWidget {
  const _AddScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentCard(
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 10.0),
          SizedBox(
            height: MediaQuery.of(context).size.height - 142.0,
            child: BlocConsumer<AddCubit, AddState>(
              listenWhen: (previous, current) =>
                  previous.runtimeType != current.runtimeType,
              listener: (context, state) {
                if (state is AddAnalysisUnknownEngine) {
                  // TODO
                  print("TODO ManualPathDialog");
                  /*showDialog<String?>(
                    context: context,
                    builder: (context) => ManualPathDialog(
                        initialPath: formData!.absoluteTmpPath!),
                  ).then((manualGameLocation) => context
                      .read<AddCubit>()
                      .manualGameLocationSelected(manualGameLocation));*/
                } else if (state is AddAnalysisUnityEngine) {
                  // TODO
                  print("TODO UnityWarningDialog");
                  /*showDialog(
                    context: context,
                    builder: (context) => UnityWarningDialog(
                        absoluteGamePath: formData!.absoluteTmpPath!),
                  ).then((value) => context
                      .read<AddCubit>()
                      .startForms());*/
                }
              },
              buildWhen: (previous, current) =>
                  previous.runtimeType != current.runtimeType ||
                  (previous as AddForms).activeStepperIndex !=
                      (current as AddForms).activeStepperIndex,
              builder: (context, state) {
                // TODO if this page is still shown during install running
                /* if (gameDatabaseProvider.isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        Text("Creating game..."),
                      ],
                    ),
                  );
                }*/

                // TODO handle AddAnalysisFailed
                if (state is AddInitial ||
                    state is AddAnalysing ||
                    state is AddAnalysisUnknownEngine ||
                    state is AddAnalysisUnityEngine) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        Text("Analyzing..."),
                      ],
                    ),
                  );
                } else if (state is AddForms) {
                  return Stepper(
                    type: StepperType.horizontal,
                    //physics: NeverScrollableScrollPhysics(),
                    currentStep: state.activeStepperIndex,
                    controlsBuilder: (context, controlDetails) {
                      return const SizedBox.shrink();
                    },
                    steps: [
                      Step(
                        title: const Text("Metadata"),
                        content: const MetadataForm(),
                        isActive: state.activeStepperIndex >= 0,
                        state: state.activeStepperIndex >= 0
                            ? StepState.complete
                            : StepState.disabled,
                      ),
                      Step(
                        title: const Text("Details"),
                        content: const DetailsForm(),
                        isActive: state.activeStepperIndex >= 1,
                        state: state.activeStepperIndex >= 1
                            ? StepState.complete
                            : StepState.disabled,
                      ),
                      Step(
                        title: const Text("Images"),
                        content: const ImagesForm(),
                        isActive: state.activeStepperIndex >= 2,
                        state: state.activeStepperIndex >= 2
                            ? StepState.complete
                            : StepState.disabled,
                      ),
                    ],
                  );
                } else if (state is AddAnalysisFailed) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline),
                        Text(state.error),
                      ],
                    ),
                  );
                } else {
                  throw UnhandledStateException(state: state.runtimeType);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: BlocBuilder<AddCubit, AddState>(
            builder: (context, state) {
              return IconButton(
                splashRadius: 20.0,
                onPressed: () {
                  // TODO unsure how to detect editing started
                  showDialog(
                    context: context,
                    builder: (context) => const ConfirmationDialog.leavePage(),
                  ).then((value) {
                    if (value) {
                      context.pop();
                    }
                  });
                },
                icon: const Icon(Icons.arrow_back),
              );
            },
          ),
        ),
        const SizedBox(width: 10.0),
        Text(
          textAlign: TextAlign.center,
          "New game",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }
}
