import 'package:dartz/dartz.dart';
import '../../core/error/failure.dart';
import '../entities/recording.dart';
import '../repositories/recording_repository.dart';

class GetAllRecordings {
  final RecordingRepository repository;

  GetAllRecordings({required this.repository});

  Future<Either<Failure, List<Recording>>> call() async {
    return await repository.getAllRecordings();
  }
}
