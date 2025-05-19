import 'package:dartz/dartz.dart';

import '../../core/error/failure.dart';
import '../entities/recording.dart';
import '../repositories/recording_repository.dart';

class SaveRecording {
  final RecordingRepository repository;

  SaveRecording({required this.repository});

  Future<Either<Failure, Recording>> call({
    required int durationInSeconds,
    required Function(bool) onRecordingStatus,
  }) async {
    return await repository.saveRecording(
      durationInSeconds: durationInSeconds,
      onRecordingStatus: onRecordingStatus,
    );
  }

  Future<Either<Failure, Recording>> stopRecording() async {
    return await repository.stopRecording();
  }

  bool isRecording() {
    return repository.isRecording();
  }
}
