class UnhandledStateException implements Exception {
  final String message;

  UnhandledStateException({required Type state})
      : message = "Unhandled state ${state.toString()}";
}
