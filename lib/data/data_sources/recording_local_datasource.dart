import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screen_recorder/screen_recorder.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../../core/constants/app_constants.dart';
import '../../core/error/exceptions.dart';
import '../../core/utils/date_formater.dart';
import '../models/recording_model.dart';

abstract class RecordingLocalDataSource {
  /// Gets all locally stored recordings
  Future<List<RecordingModel>> getAllRecordings();

  /// Records the screen for the given duration
  Future<RecordingModel> recordScreen({
    required int durationInSeconds,
    required Function(bool) onRecordingStatus,
  });

  /// Stops the ongoing recording
  Future<RecordingModel> stopRecording();

  /// Plays a specific recording
  Future<void> playRecording(String recordingId);

  /// Checks if recording is in progress
  bool isRecording();

  /// Deletes a recording
  Future<bool> deleteRecording(String recordingId);
}

class RecordingLocalDataSourceImpl implements RecordingLocalDataSource {
  final _screenRecorderController = ScreenRecorderController();
  final _uuid = const Uuid();
  VideoPlayerController? _videoPlayerController;
  bool _isRecording = false;
  String? _currentRecordingPath;
  int? _currentRecordingDuration;
  DateTime? _currentRecordingStartTime;

  // Metadata file to store recording information
  static const String _metadataFileName = 'recordings_metadata.json';

  @override
  Future<List<RecordingModel>> getAllRecordings() async {
    try {
      final directory = await _getRecordingsDirectory();
      final metadataFile = File('${directory.path}/$_metadataFileName');

      // If metadata file doesn't exist, return empty list
      if (!await metadataFile.exists()) {
        return [];
      }

      // Read metadata file
      final jsonString = await metadataFile.readAsString();
      final List<dynamic> jsonList = json.decode(jsonString);

      // Convert to List<RecordingModel>
      return jsonList.map((e) => RecordingModel.fromJson(e)).toList();
    } catch (e) {
      throw RecordingStorageException(details: e.toString());
    }
  }

  @override
  Future<RecordingModel> recordScreen({
    required int durationInSeconds,
    required Function(bool) onRecordingStatus,
  }) async {
    try {
      // Check if already recording
      if (_isRecording) {
        throw RecordingException('Recording already in progress');
      }

      // Request permissions
      final hasPermission = await _checkAndRequestPermissions();
      if (!hasPermission) {
        throw RecordingPermissionException();
      }

      // Setup recording path
      final directory = await _getRecordingsDirectory();
      final recordingId = _uuid.v4();
      final dateFormatted = DateFormatter.formatDateTimeForFilename(
        DateTime.now(),
      );
      final fileName =
          '${AppConstants.recordingFilePrefix}$dateFormatted${AppConstants.recordingFileExtension}';
      final filePath = '${directory.path}/$fileName';

      // Start recording with controller
      _isRecording = true;
      _currentRecordingPath = filePath;
      _currentRecordingDuration = durationInSeconds;
      _currentRecordingStartTime = DateTime.now();
      onRecordingStatus(true);

      // Start recording
      _screenRecorderController.start();

      // Setup automatic stop after duration
      Future.delayed(Duration(seconds: durationInSeconds), () async {
        if (_isRecording) {
          await stopRecording();
        }
      });

      // Return recording model immediately, actual file will be created when recording stops
      final recordingModel = RecordingModel(
        id: recordingId,
        filePath: filePath,
        recordedAt: _currentRecordingStartTime!,
        durationInSeconds: durationInSeconds,
        fileName: fileName,
      );

      return recordingModel;
    } catch (e) {
      _isRecording = false;
      onRecordingStatus(false);
      throw RecordingInitException(details: e.toString());
    }
  }

  @override
  Future<RecordingModel> stopRecording() async {
    try {
      if (!_isRecording) {
        throw RecordingException('No recording in progress');
      }

      // Calculate actual duration
      final recordingEndTime = DateTime.now();
      final actualDuration =
          recordingEndTime.difference(_currentRecordingStartTime!).inSeconds;

      // Stop recording
      _screenRecorderController.stop();
      _isRecording = false;

      String filePath = '';
      // Export as video file
      final exportResult = await _exportRecording(_currentRecordingPath!);
      if (exportResult != null) {
        filePath = exportResult;
      } else {
        throw RecordingException('Failed to export recording');
      }

      // Create recording model
      final recordingId = _uuid.v4();
      final fileName = filePath.split('/').last;

      final recordingModel = RecordingModel(
        id: recordingId,
        filePath: filePath,
        recordedAt: _currentRecordingStartTime!,
        durationInSeconds: actualDuration,
        fileName: fileName,
      );

      // Save metadata
      await _saveRecordingMetadata(recordingModel);

      // Reset current recording data
      _currentRecordingPath = null;
      _currentRecordingDuration = null;
      _currentRecordingStartTime = null;

      return recordingModel;
    } catch (e) {
      _isRecording = false;
      throw RecordingException('Failed to stop recording: ${e.toString()}');
    }
  }

  // Helper method to export recording as a video file
  Future<String?> _exportRecording(String outputPath) async {
    try {
      // Based on the example, we need to use the exporter to create a file
      // This implementation might need adjustment based on your needs
      if (!_screenRecorderController.exporter.hasFrames) {
        throw RecordingException('No frames to export');
      }

      // Export as video using FFmpeg or another method
      // This is a placeholder - actual implementation depends on your requirements
      // You might need to use a package like ffmpeg_kit_flutter to convert frames to a video

      // For now, we'll export frames and save them as a placeholder
      final frames = await _screenRecorderController.exporter.exportFrames();
      if (frames == null || frames.isEmpty) {
        throw RecordingException('Failed to export frames');
      }

      // In a real implementation, you would convert these frames to a video
      // For this example, we'll just return the path
      return outputPath;
    } catch (e) {
      throw RecordingException('Failed to export recording: ${e.toString()}');
    }
  }

  @override
  Future<void> playRecording(String recordingId) async {
    try {
      // Find recording by ID
      final recordings = await getAllRecordings();
      final recording = recordings.firstWhere(
        (element) => element.id == recordingId,
        orElse:
            () =>
                throw FileNotFoundException(
                  details: 'Recording ID: $recordingId not found',
                ),
      );

      // Check if file exists
      final file = File(recording.filePath);
      if (!await file.exists()) {
        throw FileNotFoundException(
          details: 'File at ${recording.filePath} not found',
        );
      }

      // Dispose previous controller if exists
      await _videoPlayerController?.dispose();

      // Initialize video player
      _videoPlayerController = VideoPlayerController.file(file);
      await _videoPlayerController!.initialize();

      // Play video
      await _videoPlayerController!.play();
    } catch (e) {
      throw PlaybackException('Failed to play recording: ${e.toString()}');
    }
  }

  @override
  bool isRecording() {
    return _isRecording;
  }

  @override
  Future<bool> deleteRecording(String recordingId) async {
    try {
      // Find recording by ID
      final recordings = await getAllRecordings();
      final recordingIndex = recordings.indexWhere(
        (element) => element.id == recordingId,
      );

      if (recordingIndex == -1) {
        throw FileNotFoundException(
          details: 'Recording ID: $recordingId not found',
        );
      }

      final recording = recordings[recordingIndex];

      // Delete file
      final file = File(recording.filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Update metadata
      recordings.removeAt(recordingIndex);
      await _saveRecordingsListMetadata(recordings);

      return true;
    } catch (e) {
      throw PlaybackException('Failed to delete recording: ${e.toString()}');
    }
  }

  // Private helper methods
  Future<Directory> _getRecordingsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final recordingsDir = Directory(
      '${appDir.path}/${AppConstants.recordingsDirectoryName}',
    );

    // Create directory if it doesn't exist
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }

    return recordingsDir;
  }

  Future<bool> _checkAndRequestPermissions() async {
    // For Android, we need storage permission
    if (Platform.isAndroid) {
      final storageStatus = await Permission.storage.status;
      if (storageStatus.isDenied) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      return storageStatus.isGranted;
    }

    // For iOS, we need photos permission (to save recordings)
    if (Platform.isIOS) {
      final photosStatus = await Permission.photos.status;
      if (photosStatus.isDenied) {
        final result = await Permission.photos.request();
        return result.isGranted;
      }
      return photosStatus.isGranted;
    }

    return false;
  }

  Future<void> _saveRecordingMetadata(RecordingModel recording) async {
    final recordings = await getAllRecordings();
    recordings.add(recording);
    await _saveRecordingsListMetadata(recordings);
  }

  Future<void> _saveRecordingsListMetadata(
    List<RecordingModel> recordings,
  ) async {
    try {
      final directory = await _getRecordingsDirectory();
      final metadataFile = File('${directory.path}/$_metadataFileName');

      // Convert recordings to JSON
      final jsonList = recordings.map((e) => e.toJson()).toList();
      final jsonString = json.encode(jsonList);

      // Write to file
      await metadataFile.writeAsString(jsonString);
    } catch (e) {
      throw RecordingStorageException(details: e.toString());
    }
  }

  // Getter for video player controller
  VideoPlayerController? get videoPlayerController => _videoPlayerController;

  // Getter for screen recorder controller
  ScreenRecorderController get screenRecorderController =>
      _screenRecorderController;
}
