import 'package:flutter/foundation.dart';

import '../../domain/entities/quiz_questions.dart';
import '../../domain/usecases/quiz_usecase.dart';

enum QuizState { initial, loading, answering, submitting, completed, error }

class QuizViewModel with ChangeNotifier {
  final GetQuizQuestions getQuizQuestionsUseCase;
  final SubmitQuizAnswers submitQuizAnswersUseCase;
  final ResetQuiz resetQuizUseCase;

  QuizViewModel({
    required this.getQuizQuestionsUseCase,
    required this.submitQuizAnswersUseCase,
    required this.resetQuizUseCase,
  });

  // State management
  QuizState _quizState = QuizState.initial;
  List<QuizQuestion> _questions = [];
  List<int?> _selectedAnswers = [];
  QuizResult? _quizResult;
  String? _errorMessage;
  int _currentQuestionIndex = 0;

  // Getters
  QuizState get quizState => _quizState;
  List<QuizQuestion> get questions => _questions;
  List<int?> get selectedAnswers => _selectedAnswers;
  QuizResult? get quizResult => _quizResult;
  String? get errorMessage => _errorMessage;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get totalQuestions => _questions.length;
  bool get canMoveToNextQuestion => _currentQuestionIndex < totalQuestions - 1;
  bool get isLastQuestion => _currentQuestionIndex == totalQuestions - 1;
  bool get canSubmitCurrentAnswer =>
      _selectedAnswers[_currentQuestionIndex] != null;

  // Initialize quiz
  Future<void> initQuiz() async {
    _quizState = QuizState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await getQuizQuestionsUseCase();

    result.fold(
      (failure) {
        _quizState = QuizState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (questions) {
        _questions = questions;
        _selectedAnswers = List.filled(_questions.length, null);
        _currentQuestionIndex = 0;
        _quizState = QuizState.answering;
        notifyListeners();
      },
    );
  }

  // Select answer for current question
  void selectAnswer(int answerIndex) {
    if (_quizState != QuizState.answering) return;

    _selectedAnswers[_currentQuestionIndex] = answerIndex;
    notifyListeners();
  }

  // Move to next question
  void nextQuestion() {
    if (!canMoveToNextQuestion || _quizState != QuizState.answering) return;

    _currentQuestionIndex++;
    notifyListeners();
  }

  // Move to previous question
  void previousQuestion() {
    if (_currentQuestionIndex <= 0 || _quizState != QuizState.answering) return;

    _currentQuestionIndex--;
    notifyListeners();
  }

  // Submit quiz
  Future<void> submitQuiz() async {
    // Validate all questions are answered
    if (_selectedAnswers.contains(null)) {
      _errorMessage = 'Please answer all questions before submitting';
      notifyListeners();
      return;
    }

    _quizState = QuizState.submitting;
    _errorMessage = null;
    notifyListeners();

    final result = await submitQuizAnswersUseCase(
      _selectedAnswers.whereType<int>().toList(),
    );

    result.fold(
      (failure) {
        _quizState = QuizState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (quizResult) {
        _quizResult = quizResult;
        _quizState = QuizState.completed;
        notifyListeners();
      },
    );
  }

  // Reset quiz
  Future<void> resetQuiz() async {
    _quizState = QuizState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await resetQuizUseCase();

    result.fold(
      (failure) {
        _quizState = QuizState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (_) {
        _questions = [];
        _selectedAnswers = [];
        _quizResult = null;
        _currentQuestionIndex = 0;
        initQuiz();
      },
    );
  }
}
