part of 'paginated_wrap_cubit.dart';

final class PaginatedWrapState extends Equatable {
  const PaginatedWrapState({required this.currentPage});

  final int currentPage;

  PaginatedWrapState copyWith({
    int? currentPage,
    List<Widget>? items,
  }) {
    return PaginatedWrapState(
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object> get props => [currentPage];
}
