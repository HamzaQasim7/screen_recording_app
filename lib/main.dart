import 'package:flutter/material.dart';
import 'package:job_test/presentation/app.dart';

import 'core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  runApp(const ScreenRecorderApp());
}
