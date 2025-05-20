import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/quiz_progress_indicator.dart';
import '../view_models/quiz_viewmodel.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize quiz when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizViewModel>().initQuiz();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Quiz'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue, Colors.indigo],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFE3F2FD)],
          ),
        ),
        child: Consumer<QuizViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.quizState == QuizState.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (viewModel.quizState == QuizState.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${viewModel.errorMessage}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => viewModel.initQuiz(),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            } else if (viewModel.quizState == QuizState.completed) {
              // Navigate to result screen
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const QuizResultScreen(),
                  ),
                );
              });
              return const Center(child: CircularProgressIndicator());
            } else if (viewModel.questions.isEmpty) {
              return const Center(child: Text('No questions available'));
            }

            // Normal quiz answering state
            final currentQuestion =
                viewModel.questions[viewModel.currentQuestionIndex];

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Progress indicator
                    QuizProgressIndicator(
                      currentQuestion: viewModel.currentQuestionIndex + 1,
                      totalQuestions: viewModel.totalQuestions,
                    ),
                    const SizedBox(height: 24),

                    // Question card
                    Expanded(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentQuestion.question,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 24),

                              // Options
                              Expanded(
                                child: ListView.separated(
                                  itemCount: currentQuestion.options.length,
                                  separatorBuilder:
                                      (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    return QuizOptionItem(
                                      option: currentQuestion.options[index],
                                      index: index,
                                      isSelected:
                                          viewModel.selectedAnswers[viewModel
                                              .currentQuestionIndex] ==
                                          index,
                                      onTap:
                                          () => viewModel.selectAnswer(index),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Navigation buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (viewModel.currentQuestionIndex > 0)
                          ElevatedButton.icon(
                            onPressed: () => viewModel.previousQuestion(),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Previous'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black87,
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        ElevatedButton.icon(
                          onPressed:
                              viewModel.canSubmitCurrentAnswer
                                  ? viewModel.isLastQuestion
                                      ? () => viewModel.submitQuiz()
                                      : () => viewModel.nextQuestion()
                                  : null,
                          icon: Icon(
                            viewModel.isLastQuestion
                                ? Icons.check_circle
                                : Icons.arrow_forward,
                          ),
                          label: Text(
                            viewModel.isLastQuestion ? 'Submit' : 'Next',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
