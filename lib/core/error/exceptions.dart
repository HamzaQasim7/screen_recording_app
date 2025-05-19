// Base exception class
class AppException implements Exception {
  final String message;
  final String? details;
  final StackTrace? stackTrace;

  AppException(this.message, {this.details, this.stackTrace});

  @override
  String toString() =>
      'AppException: $message${details != null ? '\nDetails: $details' : ''}';
}

// Recording-specific exceptions
class RecordingException extends AppException {
  RecordingException(super.message, {super.details, super.stackTrace});
}

class RecordingPermissionException extends RecordingException {
  RecordingPermissionException({String? details, StackTrace? stackTrace})
    : super(
        'Recording permission denied',
        details: details,
        stackTrace: stackTrace,
      );
}

class RecordingStorageException extends RecordingException {
  RecordingStorageException({String? details, StackTrace? stackTrace})
    : super(
        'Failed to store recording',
        details: details,
        stackTrace: stackTrace,
      );
}

class RecordingInitException extends RecordingException {
  RecordingInitException({String? details, StackTrace? stackTrace})
    : super(
        'Failed to initialize recording',
        details: details,
        stackTrace: stackTrace,
      );
}

// Playback-specific exceptions
class PlaybackException extends AppException {
  PlaybackException(super.message, {super.details, super.stackTrace});
}

class FileNotFoundException extends PlaybackException {
  FileNotFoundException({String? details, StackTrace? stackTrace})
    : super(
        'Recording file not found',
        details: details,
        stackTrace: stackTrace,
      );
}

class InvalidRecordingException extends PlaybackException {
  InvalidRecordingException({String? details, StackTrace? stackTrace})
    : super('Invalid recording file', details: details, stackTrace: stackTrace);
}
