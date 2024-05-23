class NotFoundException implements Exception {
  final String message;
  const NotFoundException(String resource) : message = "$resource not Found";
}
