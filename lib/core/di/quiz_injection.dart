// Add this to the existing init() function in your injection_container.dart
import 'package:get_it/get_it.dart';

import '../../data/data_sources/quiz_local_datasorce.dart';
import '../../data/repositories/quiz_repository_impl.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../../domain/usecases/quiz_usecase.dart';
import '../../presentation/view_models/quiz_viewmodel.dart';

Future<void> initQuizDependencies(GetIt sl) async {
  // View Models
  sl.registerFactory(
    () => QuizViewModel(
      getQuizQuestionsUseCase: sl(),
      submitQuizAnswersUseCase: sl(),
      resetQuizUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetQuizQuestions(repository: sl()));
  sl.registerLazySingleton(() => SubmitQuizAnswers(repository: sl()));
  sl.registerLazySingleton(() => ResetQuiz(repository: sl()));

  // Repository
  sl.registerLazySingleton<QuizRepository>(
    () => QuizRepositoryImpl(localDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<QuizLocalDataSource>(
    () => QuizLocalDataSourceImpl(),
  );
}
