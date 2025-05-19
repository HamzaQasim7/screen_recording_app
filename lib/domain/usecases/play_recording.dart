import 'package:dartz/dartz.dart';

import '../../core/error/failure.dart';
import '../repositories/recording_repository.dart';

class PlayRecording {
  final RecordingRepository repository;

  PlayRecording({required this.repository});

  Future<Either<Failure, void>> call(String recordingId) async {
    return await repository.playRecording(recordingId);
  }

  Future<Either<Failure, bool>> deleteRecording(String recordingId) async {
    return await repository.deleteRecording(recordingId);
  }
}
