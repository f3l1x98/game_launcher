part of 'guide_tab_cubit.dart';

final class GuideTabState extends Equatable {
  const GuideTabState({
    required this.editMode,
    required this.game,
  });

  final bool editMode;
  final GameModel game;

  GuideTabState copyWith({
    bool? editMode,
    GameModel? game,
  }) {
    return GuideTabState(
      editMode: editMode ?? this.editMode,
      game: game ?? this.game,
    );
  }

  @override
  List<Object> get props => [editMode, game];
}
