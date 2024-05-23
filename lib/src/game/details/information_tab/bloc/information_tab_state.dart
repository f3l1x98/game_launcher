part of 'information_tab_bloc.dart';

sealed class InformationTabState extends Equatable {
  const InformationTabState();

  @override
  List<Object> get props => [];
}

final class InformationTabInitial extends InformationTabState {}

final class InformationTabLoaded extends InformationTabState {
  const InformationTabLoaded({
    this.prequel,
    this.sequel,
  });

  final GameModel? prequel;
  final GameModel? sequel;

  @override
  List<Object> get props => [];
}
