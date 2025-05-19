import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failure.dart';
import '../../domain/entities/recording.dart';
import '../../domain/repositories/recording_repository.dart';
import '../data_sources/recording_local_datasource.dart';

class RecordingRepositoryImpl implements RecordingRepository {
  final RecordingLocalDataSource localDataSource;

  RecordingRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Recording>>> getAllRecordings() async {
    try {
      final recordingModels = await localDataSource.getAllRecordings();
      return Right(recordingModels);
    } on RecordingStorageException catch (e) {
      return Left(RecordingStorageFailure(details: e.toString()));
    } catch (e) {
      return Left(
        RecordingFailure(
          message: 'Failed to get recordings',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Recording>> saveRecording({
    required int durationInSeconds,
    required Function(bool) onRecordingStatus,
  }) async {
    try {
      final recordingModel = await localDataSource.recordScreen(
        durationInSeconds: durationInSeconds,
        onRecordingStatus: onRecordingStatus,
      );
      return Right(recordingModel);
    } on RecordingPermissionException catch (e) {
      return Left(PermissionFailure(details: e.toString()));
    } on RecordingInitException catch (e) {
      return Left(RecordingInitFailure(details: e.toString()));
    } on RecordingStorageException catch (e) {
      return Left(RecordingStorageFailure(details: e.toString()));
    } catch (e) {
      return Left(
        RecordingFailure(
          message: 'Failed to save recording',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Recording>> stopRecording() async {
    try {
      final recordingModel = await localDataSource.stopRecording();
      return Right(recordingModel);
    } on RecordingException catch (e) {
      return Left(RecordingFailure(message: e.message, details: e.details));
    } catch (e) {
      return Left(
        RecordingFailure(
          message: 'Failed to stop recording',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> playRecording(String recordingId) async {
    try {
      await localDataSource.playRecording(recordingId);
      return const Right(null);
    } on FileNotFoundException catch (e) {
      return Left(FileNotFoundFailure(details: e.toString()));
    } on PlaybackException catch (e) {
      return Left(PlaybackFailure(message: e.message, details: e.details));
    } catch (e) {
      return Left(
        PlaybackFailure(
          message: 'Failed to play recording',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  bool isRecording() {
    return localDataSource.isRecording();
  }

  @override
  Future<Either<Failure, bool>> deleteRecording(String recordingId) async {
    try {
      final result = await localDataSource.deleteRecording(recordingId);
      return Right(result);
    } on FileNotFoundException catch (e) {
      return Left(FileNotFoundFailure(details: e.toString()));
    } on PlaybackException catch (e) {
      return Left(PlaybackFailure(message: e.message, details: e.details));
    } catch (e) {
      return Left(
        PlaybackFailure(
          message: 'Failed to delete recording',
          details: e.toString(),
        ),
      );
    }
  }
}
