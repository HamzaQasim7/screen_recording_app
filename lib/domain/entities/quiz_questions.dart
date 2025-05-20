import 'package:equatable/equatable.dart';

class QuizQuestion extends Equatable {
  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
  });

  @override
  List<Object?> get props => [id, question, options, correctOptionIndex];
}

class QuizResult extends Equatable {
  final int score;
  final int totalQuestions;
  final List<bool> answers; // track which questions were answered correctly

  const QuizResult({
    required this.score,
    required this.totalQuestions,
    required this.answers,
  });

  String get feedback {
    if (score == totalQuestions) {
      return 'Excellent!';
    } else if (score >= totalQuestions * 0.6) {
      return 'Good job!';
    } else {
      return 'Keep practicing!';
    }
  }

  @override
  List<Object?> get props => [score, totalQuestions, answers];
}
