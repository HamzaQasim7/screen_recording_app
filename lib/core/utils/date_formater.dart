import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

class DateFormatter {
  // Format duration in seconds to readable string (e.g., "1m 30s")
  static String formatDuration(int durationInSeconds) {
    final minutes = durationInSeconds ~/ 60;
    final seconds = durationInSeconds % 60;

    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  // Format datetime for display in UI
  static String formatDateTimeForDisplay(DateTime dateTime) {
    return DateFormat(AppConstants.displayDateFormat).format(dateTime);
  }

  // Format datetime for filename
  static String formatDateTimeForFilename(DateTime dateTime) {
    return DateFormat(AppConstants.filenameDateFormat).format(dateTime);
  }

  // Parse datetime from filename
  static DateTime parseDateTimeFromFilename(String filename) {
    // Extract date part from filename (format: screen_recording_yyyyMMdd_HHmmss.mp4)
    final dateStr = filename.substring(
      AppConstants.recordingFilePrefix.length,
      filename.length - AppConstants.recordingFileExtension.length,
    );

    return DateFormat(AppConstants.filenameDateFormat).parse(dateStr);
  }
}
