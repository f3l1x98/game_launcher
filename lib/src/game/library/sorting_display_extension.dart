import 'package:database_repository/database_repository.dart';

extension SortingDisplayExtension on Sorting {
  static const Map<Sorting, String> _enumToDisplayName = {
    Sorting.newest: "Newest",
    Sorting.oldest: "Oldest",
    Sorting.mostVotes: "Highest voting",
    Sorting.alphabeticalAsc: "Alphabetical (A-Z)",
    Sorting.alphabeticalDesc: "Alphabetical (Z-A)",
  };

  String getDisplayName() {
    return _enumToDisplayName[this]!;
  }
}
