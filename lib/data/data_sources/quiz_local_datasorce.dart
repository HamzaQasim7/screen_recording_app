import '../../core/error/exceptions.dart';
import '../models/quiz_model.dart';

abstract class QuizLocalDataSource {
  /// Get predefined quiz questions
  Future<List<QuizQuestionModel>> getQuizQuestions();

  /// Calculate quiz result from chosen answers
  Future<QuizResultModel> submitQuizAnswers(List<int> selectedAnswers);

  /// Reset any stored state
  Future<bool> resetQuiz();
}

class QuizLocalDataSourceImpl implements QuizLocalDataSource {
  // Simulated database of 5 questions
  final List<QuizQuestionModel> _questions = [
    const QuizQuestionModel(
      id: 'q1',
      question: 'What widget is used to create a scrollable list of widgets?',
      options: ['Column', 'ListView', 'Stack', 'Container'],
      correctOptionIndex: 1,
    ),
    const QuizQuestionModel(
      id: 'q2',
      question:
          'Which of the following is a state management solution in Flutter?',
      options: ['GridView', 'Cupertino', 'Provider', 'Material'],
      correctOptionIndex: 2,
    ),
    const QuizQuestionModel(
      id: 'q3',
      question:
          'What widget would you use to create a button with text and an icon?',
      options: [
        'RaisedButton',
        'IconButton',
        'FlatButton',
        'ElevatedButton.icon',
      ],
      correctOptionIndex: 3,
    ),
    const QuizQuestionModel(
      id: 'q4',
      question: 'Which package is used for routing in Flutter applications?',
      options: ['navigator', 'page_router', 'go_router', 'route_master'],
      correctOptionIndex: 2,
    ),
    const QuizQuestionModel(
      id: 'q5',
      question: 'What is Flutter\'s programming language?',
      options: ['Dart', 'JavaScript', 'Kotlin', 'Swift'],
      correctOptionIndex: 0,
    ),
  ];

  // Track current state
  List<int>? _lastSubmittedAnswers;
  QuizResultModel? _lastResult;

  @override
  Future<List<QuizQuestionModel>> getQuizQuestions() async {
    try {
      // Simulate a network delay
      await Future.delayed(const Duration(milliseconds: 300));
      return _questions;
    } catch (e) {
      throw AppException(
        'Failed to fetch quiz questions',
        details: e.toString(),
      );
    }
  }

  @override
  Future<QuizResultModel> submitQuizAnswers(List<int> selectedAnswers) async {
    try {
      if (selectedAnswers.length != _questions.length) {
        throw AppException(
          'Invalid submission: expected ${_questions.length} answers but got ${selectedAnswers.length}',
        );
      }

      // Calculate score and track which questions were correct
      int score = 0;
      List<bool> answers = [];

      for (int i = 0; i < _questions.length; i++) {
        bool isCorrect = selectedAnswers[i] == _questions[i].correctOptionIndex;
        answers.add(isCorrect);
        if (isCorrect) score++;
      }

      _lastSubmittedAnswers = List.from(selectedAnswers);
      _lastResult = QuizResultModel(
        score: score,
        totalQuestions: _questions.length,
        answers: answers,
      );

      return _lastResult!;
    } catch (e) {
      throw AppException(
        'Failed to submit quiz answers',
        details: e.toString(),
      );
    }
  }

  @override
  Future<bool> resetQuiz() async {
    try {
      _lastSubmittedAnswers = null;
      _lastResult = null;
      return true;
    } catch (e) {
      throw AppException('Failed to reset quiz', details: e.toString());
    }
  }
}
