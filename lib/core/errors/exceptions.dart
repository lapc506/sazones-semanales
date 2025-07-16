// Base exception class for the application
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, {this.code});
  
  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

// Database related exceptions
class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code});
}

// Camera related exceptions
class CameraException extends AppException {
  const CameraException(super.message, {super.code});
}

// Speech recognition exceptions
class SpeechRecognitionException extends AppException {
  const SpeechRecognitionException(super.message, {super.code});
}

// Notification exceptions
class NotificationException extends AppException {
  const NotificationException(super.message, {super.code});
}

// Validation exceptions
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
}