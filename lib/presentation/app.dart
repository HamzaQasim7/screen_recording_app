import 'package:flutter/material.dart';
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
      ],
      child: MaterialApp(
        title: 'Screen Recorder App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const RecordingScreen(),
          '/playback': (context) => const PlaybackScreen(),
        },
      ),
    );
  }
}
