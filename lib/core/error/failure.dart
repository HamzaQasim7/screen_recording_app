import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? details;

  const Failure({required this.message, this.details});

  @override
  List<Object?> get props => [message, details];
}

// Recording related failures
class RecordingFailure extends Failure {
  const RecordingFailure({required super.message, super.details});
}

class PermissionFailure extends RecordingFailure {
  const PermissionFailure({super.details})
    : super(message: 'Permission denied for screen recording');
}

class RecordingInitFailure extends RecordingFailure {
  const RecordingInitFailure({super.details})
    : super(message: 'Failed to initialize screen recording');
}

class RecordingStorageFailure extends RecordingFailure {
  const RecordingStorageFailure({super.details})
    : super(message: 'Failed to store recording');
}

// Playback related failures
class PlaybackFailure extends Failure {
  const PlaybackFailure({required super.message, super.details});
}

class FileNotFoundFailure extends PlaybackFailure {
  const FileNotFoundFailure({super.details})
    : super(message: 'Recording file not found');
}

class InvalidRecordingFailure extends PlaybackFailure {
  const InvalidRecordingFailure({super.details})
    : super(message: 'Invalid recording file');
}
