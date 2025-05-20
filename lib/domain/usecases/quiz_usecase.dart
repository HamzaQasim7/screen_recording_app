import 'package:dartz/dartz.dart';

import '../../core/error/failure.dart';
import '../entities/quiz_questions.dart';
import '../repositories/quiz_repository.dart';

class GetQuizQuestions {
  final QuizRepository repository;

  GetQuizQuestions({required this.repository});

  Future<Either<Failure, List<QuizQuestion>>> call() async {
    return await repository.getQuizQuestions();
  }
}

class SubmitQuizAnswers {
  final QuizRepository repository;

  SubmitQuizAnswers({required this.repository});

  Future<Either<Failure, QuizResult>> call(List<int> selectedAnswers) async {
    return await repository.submitQuizAnswers(selectedAnswers);
  }
}

class ResetQuiz {
  final QuizRepository repository;

  ResetQuiz({required this.repository});

  Future<Either<Failure, bool>> call() async {
    return await repository.resetQuiz();
  }
}
