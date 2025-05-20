import 'package:dartz/dartz.dart';

import '../../core/error/failure.dart';
import '../entities/quiz_questions.dart';

abstract class QuizRepository {
  /// Get quiz questions
  Future<Either<Failure, List<QuizQuestion>>> getQuizQuestions();

  /// Submit quiz answers and get result
  Future<Either<Failure, QuizResult>> submitQuizAnswers(
    List<int> selectedAnswers,
  );

  /// Reset quiz state
  Future<Either<Failure, bool>> resetQuiz();
}
