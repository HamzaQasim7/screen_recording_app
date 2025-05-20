import '../../domain/entities/quiz_questions.dart';

class QuizQuestionModel extends QuizQuestion {
  const QuizQuestionModel({
    required super.id,
    required super.question,
    required super.options,
    required super.correctOptionIndex,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    return QuizQuestionModel(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctOptionIndex: json['correctOptionIndex'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
    };
  }

  factory QuizQuestionModel.fromEntity(QuizQuestion question) {
    return QuizQuestionModel(
      id: question.id,
      question: question.question,
      options: question.options,
      correctOptionIndex: question.correctOptionIndex,
    );
  }
}

class QuizResultModel extends QuizResult {
  const QuizResultModel({
    required super.score,
    required super.totalQuestions,
    required super.answers,
  });

  factory QuizResultModel.fromJson(Map<String, dynamic> json) {
    return QuizResultModel(
      score: json['score'],
      totalQuestions: json['totalQuestions'],
      answers: List<bool>.from(json['answers']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'totalQuestions': totalQuestions,
      'answers': answers,
    };
  }

  factory QuizResultModel.fromEntity(QuizResult result) {
    return QuizResultModel(
      score: result.score,
      totalQuestions: result.totalQuestions,
      answers: result.answers,
    );
  }
}
