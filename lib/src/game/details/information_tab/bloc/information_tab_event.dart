part of 'information_tab_bloc.dart';

sealed class InformationTabEvent extends Equatable {
  const InformationTabEvent();

  @override
  List<Object> get props => [];
}

final class InformationTabLoadedSuccess extends InformationTabEvent {
  const InformationTabLoadedSuccess({
    this.prequel,
    this.sequel,
  });

  final GameModel? prequel;
  final GameModel? sequel;

  @override
  List<Object> get props => [];
}
