import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'paginated_wrap_state.dart';

class PaginatedWrapCubit extends Cubit<PaginatedWrapState> {
  PaginatedWrapCubit({
    int initialPage = 0,
    this.onPageChanged,
  }) : super(PaginatedWrapState(currentPage: initialPage));

  final Function(int newPageNr)? onPageChanged;

  changePage(int newPage) {
    emit(state.copyWith(currentPage: newPage));
    if (onPageChanged != null) {
      onPageChanged!(newPage);
    }
  }
}
