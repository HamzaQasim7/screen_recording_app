import 'package:get_it/get_it.dart';

import '../../data/data_sources/recording_local_datasource.dart';
import '../../data/repositories/recording_repository_impl.dart';
import '../../domain/repositories/recording_repository.dart';
import '../../domain/usecases/get_all_recording.dart';
import '../../domain/usecases/play_recording.dart';
import '../../domain/usecases/save_recording.dart';
import '../../presentation/view_models/play_back_view_model.dart';
import '../../presentation/view_models/recording_provider.dart';
import '../../presentation/view_models/recording_view_model.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Providers
  sl.registerFactory(
    () => RecordingProvider(recordingViewModel: sl(), playbackViewModel: sl()),
  );

  // ViewModels
  sl.registerFactory(() => RecordingViewModel(saveRecordingUseCase: sl()));

  sl.registerFactory(
    () => PlaybackViewModel(
      getAllRecordingsUseCase: sl(),
      playRecordingUseCase: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetAllRecordings(repository: sl()));
  sl.registerLazySingleton(() => SaveRecording(repository: sl()));
  sl.registerLazySingleton(() => PlayRecording(repository: sl()));

  // Repositories
  sl.registerLazySingleton<RecordingRepository>(
    () => RecordingRepositoryImpl(localDataSource: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<RecordingLocalDataSource>(
    () => RecordingLocalDataSourceImpl(),
  );
}
