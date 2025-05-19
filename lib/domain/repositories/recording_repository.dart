import 'package:dartz/dartz.dart';

import '../../core/error/failure.dart';
import '../entities/recording.dart';

abstract class RecordingRepository {
  /// Retrieves all recordings
  Future<Either<Failure, List<Recording>>> getAllRecordings();

  /// Saves a recording
  Future<Either<Failure, Recording>> saveRecording({
    required int durationInSeconds,
    required Function(bool) onRecordingStatus,
  });

  /// Stops ongoing recording
  Future<Either<Failure, Recording>> stopRecording();

  /// Plays a recording
  Future<Either<Failure, void>> playRecording(String recordingId);

  /// Checks if a recording is currently in progress
  bool isRecording();

  /// Deletes a recording
  Future<Either<Failure, bool>> deleteRecording(String recordingId);
}
