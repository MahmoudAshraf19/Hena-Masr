/// Domain-level errors. Messages are for logs only:
/// the UI maps each type to a localized string.
sealed class Failure {
  const Failure(this.message);
  final String message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local storage error']);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found']);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong']);
}