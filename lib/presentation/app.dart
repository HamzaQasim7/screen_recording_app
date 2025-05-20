import 'package:flutter/material.dart';
import 'package:job_test/presentation/screens/playback_screen.dart';
import 'package:job_test/presentation/screens/quiz_screen.dart';
import 'package:job_test/presentation/screens/recording_screens.dart';
import 'package:job_test/presentation/view_models/quiz_viewmodel.dart';
import 'package:job_test/presentation/view_models/recording_provider.dart';
import 'package:provider/provider.dart';

import '../core/di/injection_container.dart';

class ScreenRecorderApp extends StatelessWidget {
  const ScreenRecorderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<RecordingProvider>()),
        ChangeNotifierProvider(create: (_) => sl<QuizViewModel>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Screen Recorder App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
          cardTheme: CardTheme(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: QuizScreen(),
        // initialRoute: '/',
        // routes: {
        //   '/': (context) => const RecordingScreen(),
        //   '/playback': (context) => const PlaybackScreen(),
        // },
      ),
    );
  }
}
