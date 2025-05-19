class AppConstants {
  static const String appName = 'Screen Recorder App';

  // Recording durations in seconds
  static const List<int> recordingDurations = [15, 30, 60, 120];

  // Storage directory name for recordings
  static const String recordingsDirectoryName = 'app_recordings';

  // File prefix for recordings
  static const String recordingFilePrefix = 'screen_recording_';

  // File extension for recordings
  static const String recordingFileExtension = '.mp4';

  // Date format for recording filenames
  static const String filenameDateFormat = 'yyyyMMdd_HHmmss';

  // Date format for UI display
  static const String displayDateFormat = 'MMM dd, yyyy - HH:mm:ss';
}
