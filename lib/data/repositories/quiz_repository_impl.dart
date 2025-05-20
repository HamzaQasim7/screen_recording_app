import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failure.dart';
import '../../domain/entities/quiz_questions.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../data_sources/quiz_local_datasorce.dart';

class QuizRepositoryImpl implements QuizRepository {
  final QuizLocalDataSource localDataSource;

  QuizRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<QuizQuestion>>> getQuizQuestions() async {
    try {
      final questions = await localDataSource.getQuizQuestions();
      return Right(questions);
    } on AppException catch (e) {
      return Left(
        Failure(message: 'Failed to get quiz questions', details: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, QuizResult>> submitQuizAnswers(
    List<int> selectedAnswers,
  ) async {
    try {
      final result = await localDataSource.submitQuizAnswers(selectedAnswers);
      return Right(result);
    } on AppException catch (e) {
      return Left(
        Failure(
          message: 'Failed to submit quiz answers',
          details: e.toString(),
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> resetQuiz() async {
    try {
      final result = await localDataSource.resetQuiz();
      return Right(result);
    } on AppException catch (e) {
      return Left(
        Failure(message: 'Failed to reset quiz', details: e.toString()),
      );
    }
  }
}
