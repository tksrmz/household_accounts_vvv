class RepositoryException implements Exception {
  final String message;

  RepositoryException([this.message = 'default message']);

  @override
  String toString() => 'RepositoryException: $message';
}
