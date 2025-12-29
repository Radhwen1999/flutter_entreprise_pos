/// Base exception class
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Server exception - API errors
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    super.message = 'Server error occurred',
    super.code,
    super.originalError,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

/// Cache exception - Local storage errors
class CacheException extends AppException {
  const CacheException({
    super.message = 'Cache error occurred',
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'CacheException: $message';
}

/// Network exception - No internet connection
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// Authentication exception
class AuthException extends AppException {
  const AuthException({
    super.message = 'Authentication failed',
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'AuthException: $message';
}

/// Validation exception - Input validation errors
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    super.message = 'Validation failed',
    super.code,
    super.originalError,
    this.fieldErrors,
  });

  @override
  String toString() => 'ValidationException: $message';
}

/// Not found exception - Resource not found
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Resource not found',
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'NotFoundException: $message';
}

/// Sync exception - Data synchronization errors
class SyncException extends AppException {
  const SyncException({
    super.message = 'Sync failed',
    super.code,
    super.originalError,
  });

  @override
  String toString() => 'SyncException: $message';
}
