import 'package:flutter/material.dart';
import 'package:job_test/presentation/app.dart';

import 'core/di/injection_container.dart' as di;
import 'core/di/quiz_injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();
  await initQuizDependencies(di.sl);

  runApp(const ScreenRecorderApp());
}
