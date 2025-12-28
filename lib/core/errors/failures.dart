import 'package:equatable/equatable.dart';

/// Base failure class
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Server failure - API errors
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error occurred. Please try again.',
    super.code,
  });
}

/// Cache failure - Local storage errors
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Cache error occurred. Please try again.',
    super.code,
  });
}

/// Network failure - No internet connection
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code,
  });
}

/// Authentication failure - General auth errors
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Authentication failed. Please try again.',
    super.code,
  });
}

/// Invalid credentials failure
class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure({
    super.message = 'Invalid email or password.',
    super.code,
  });
}

/// Validation failure - Input validation errors
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    super.message = 'Validation failed. Please check your input.',
    super.code,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Not found failure - Resource not found
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'The requested resource was not found.',
    super.code,
  });
}

/// Permission denied failure
class PermissionDeniedFailure extends Failure {
  const PermissionDeniedFailure({
    super.message = 'You do not have permission to perform this action.',
    super.code,
  });
}

/// Sync failure - Data synchronization errors
class SyncFailure extends Failure {
  const SyncFailure({
    super.message = 'Failed to sync data. Please try again.',
    super.code,
  });
}

/// Unknown failure - Unexpected errors
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'An unexpected error occurred. Please try again.',
    super.code,
  });
}

/// Failure mapper utility
class FailureMapper {
  static String mapFailureToMessage(Failure failure) {
    return failure.message;
  }

  static Failure mapExceptionToFailure(Exception exception) {
    final message = exception.toString();
    
    if (message.contains('SocketException') || 
        message.contains('NetworkException')) {
      return const NetworkFailure();
    }
    
    if (message.contains('CacheException')) {
      return const CacheFailure();
    }
    
    if (message.contains('AuthException')) {
      return const AuthFailure();
    }
    
    return UnknownFailure(message: message);
  }
}
