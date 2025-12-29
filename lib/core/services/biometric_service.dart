import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Biometric authentication service
class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if device supports biometrics
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  /// Check if biometrics are available and enrolled
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  /// Get list of available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// Check if fingerprint is available
  Future<bool> hasFingerprintSupport() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.fingerprint);
  }

  /// Check if face ID is available
  Future<bool> hasFaceIdSupport() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.face);
  }

  /// Authenticate with biometrics
  Future<BiometricResult> authenticate({
    String reason = 'Please authenticate to continue',
    bool biometricOnly = false,
  }) async {
    try {
      // Check if device supports biometrics
      final isSupported = await isDeviceSupported();
      if (!isSupported) {
        return BiometricResult(
          success: false,
          error: BiometricError.notSupported,
          message: 'Biometric authentication is not supported on this device',
        );
      }

      // Check if biometrics are available
      final canCheck = await canCheckBiometrics();
      if (!canCheck) {
        return BiometricResult(
          success: false,
          error: BiometricError.notEnrolled,
          message: 'No biometrics enrolled. Please set up biometrics in device settings.',
        );
      }

      // Attempt authentication
      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: biometricOnly,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        return BiometricResult(
          success: true,
          message: 'Authentication successful',
        );
      } else {
        return BiometricResult(
          success: false,
          error: BiometricError.failed,
          message: 'Authentication failed',
        );
      }
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    } catch (e) {
      return BiometricResult(
        success: false,
        error: BiometricError.unknown,
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Cancel ongoing authentication
  Future<void> cancelAuthentication() async {
    await _localAuth.stopAuthentication();
  }

  /// Handle platform exceptions
  BiometricResult _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case 'NotAvailable':
        return BiometricResult(
          success: false,
          error: BiometricError.notAvailable,
          message: 'Biometric authentication is not available',
        );
      case 'NotEnrolled':
        return BiometricResult(
          success: false,
          error: BiometricError.notEnrolled,
          message: 'No biometrics enrolled on this device',
        );
      case 'LockedOut':
        return BiometricResult(
          success: false,
          error: BiometricError.lockedOut,
          message: 'Too many failed attempts. Please try again later.',
        );
      case 'PermanentlyLockedOut':
        return BiometricResult(
          success: false,
          error: BiometricError.permanentlyLockedOut,
          message: 'Biometrics are permanently locked. Please use your device passcode.',
        );
      default:
        return BiometricResult(
          success: false,
          error: BiometricError.unknown,
          message: e.message ?? 'An unknown error occurred',
        );
    }
  }
}

/// Biometric authentication result
class BiometricResult {
  final bool success;
  final BiometricError? error;
  final String message;

  BiometricResult({
    required this.success,
    this.error,
    required this.message,
  });
}

/// Biometric error types
enum BiometricError {
  notSupported,
  notAvailable,
  notEnrolled,
  lockedOut,
  permanentlyLockedOut,
  failed,
  cancelled,
  unknown,
}
