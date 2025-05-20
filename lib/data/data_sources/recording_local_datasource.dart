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
  Future<List<RecordingModel>> getAllRecordings();
  Future<RecordingModel> recordScreen({
    required int durationInSeconds,
    required Function(bool) onRecordingStatus,
  });
  Future<RecordingModel> stopRecording();
  Future<void> playRecording(String recordingId);
  bool isRecording();
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

  static const String _metadataFileName = 'recordings_metadata.json';

  @override
  Future<List<RecordingModel>> getAllRecordings() async {
    try {
      final directory = await _getRecordingsDirectory();
      final metadataFile = File('${directory.path}/$_metadataFileName');
      if (!await metadataFile.exists()) return [];

      final jsonString = await metadataFile.readAsString();
      final List<dynamic> jsonList = json.decode(jsonString);
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
      if (_isRecording) {
        throw RecordingException('Recording already in progress');
      }

      final hasPermission = await _checkAndRequestPermissions();
      if (!hasPermission) {
        throw RecordingPermissionException();
      }

      final directory = await _getRecordingsDirectory();
      final recordingId = _uuid.v4();
      final dateFormatted = DateFormatter.formatDateTimeForFilename(
        DateTime.now(),
      );
      final fileName =
          '${AppConstants.recordingFilePrefix}$dateFormatted${AppConstants.recordingFileExtension}';
      final filePath = '${directory.path}/$fileName';

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      _isRecording = true;
      _currentRecordingPath = filePath;
      _currentRecordingDuration = durationInSeconds;
      _currentRecordingStartTime = DateTime.now();
      onRecordingStatus(true);

      await Future.delayed(const Duration(milliseconds: 300));
      _screenRecorderController.start();
      await Future.delayed(const Duration(seconds: 1));

      Future.delayed(Duration(seconds: durationInSeconds), () async {
        if (_isRecording) {
          try {
            await stopRecording();
          } catch (e) {
            print('Auto stop error: $e');
          }
        }
      });

      return RecordingModel(
        id: recordingId,
        filePath: filePath,
        recordedAt: _currentRecordingStartTime!,
        durationInSeconds: durationInSeconds,
        fileName: fileName,
      );
    } catch (e) {
      _isRecording = false;
      onRecordingStatus(false);
      throw RecordingInitException(details: e.toString());
    }
  }

  @override
  Future<RecordingModel> stopRecording() async {
    try {
      if (!_isRecording || _currentRecordingPath == null) {
        throw RecordingException('No recording in progress');
      }

      final recordingEndTime = DateTime.now();
      final actualDuration =
          recordingEndTime.difference(_currentRecordingStartTime!).inSeconds;

      final outputFile = File(_currentRecordingPath!);
      if (!await outputFile.parent.exists()) {
        await outputFile.parent.create(recursive: true);
      }

      await Future.delayed(const Duration(seconds: 1));
      _screenRecorderController.stop();
      await Future.delayed(const Duration(seconds: 1));

      _isRecording = false;

      String filePath;
      try {
        final result = await _exportRecording(_currentRecordingPath!);
        filePath =
            result ?? await _createPlaceholderFile(_currentRecordingPath!);
      } catch (e) {
        filePath = await _createPlaceholderFile(_currentRecordingPath!);
      }

      final recordingModel = RecordingModel(
        id: _uuid.v4(),
        filePath: filePath,
        recordedAt: _currentRecordingStartTime!,
        durationInSeconds: actualDuration,
        fileName: filePath.split('/').last,
      );

      await _saveRecordingMetadata(recordingModel);

      _currentRecordingPath = null;
      _currentRecordingDuration = null;
      _currentRecordingStartTime = null;

      return recordingModel;
    } catch (e) {
      _isRecording = false;
      throw RecordingException('Failed to stop recording: ${e.toString()}');
    }
  }

  Future<String?> _exportRecording(String outputPath) async {
    try {
      if (_isRecording) {
        _screenRecorderController.stop();
        _isRecording = false;
      }

      await Future.delayed(const Duration(milliseconds: 500));
      if (_screenRecorderController.exporter == null ||
          !_screenRecorderController.exporter.hasFrames) {
        throw RecordingException('No frames to export');
      }

      _screenRecorderController.exporter.exportFrames();
      return outputPath;
    } catch (e) {
      print("Export failed: $e");
      return null;
    }
  }

  Future<String> _createPlaceholderFile(String outputPath) async {
    try {
      final file = File(outputPath);
      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }
      await file.writeAsString('Recording failed. This is a placeholder file.');
      return outputPath;
    } catch (e) {
      return outputPath;
    }
  }

  @override
  Future<void> playRecording(String recordingId) async {
    try {
      final recordings = await getAllRecordings();
      final recording = recordings.firstWhere(
        (e) => e.id == recordingId,
        orElse:
            () => throw FileNotFoundException(details: 'Recording not found'),
      );

      final file = File(recording.filePath);
      if (!await file.exists()) {
        throw FileNotFoundException(
          details: 'File not found at ${recording.filePath}',
        );
      }

      await _videoPlayerController?.dispose();
      _videoPlayerController = VideoPlayerController.file(file);
      await _videoPlayerController!.initialize();
      await _videoPlayerController!.play();
    } catch (e) {
      throw PlaybackException('Failed to play recording: ${e.toString()}');
    }
  }

  @override
  bool isRecording() => _isRecording;

  @override
  Future<bool> deleteRecording(String recordingId) async {
    try {
      final recordings = await getAllRecordings();
      final index = recordings.indexWhere((r) => r.id == recordingId);

      if (index == -1) {
        throw FileNotFoundException(details: 'Recording not found');
      }

      final file = File(recordings[index].filePath);
      if (await file.exists()) {
        await file.delete();
      }

      recordings.removeAt(index);
      await _saveRecordingsListMetadata(recordings);
      return true;
    } catch (e) {
      throw PlaybackException('Failed to delete recording: ${e.toString()}');
    }
  }

  Future<bool> _checkAndRequestPermissions() async {
    List<Permission> requiredPermissions = [];

    if (Platform.isAndroid) {
      requiredPermissions = [
        Permission.storage,
        if (Permission.values.contains(Permission.accessMediaLocation))
          Permission.accessMediaLocation,
        if (Permission.values.contains(Permission.manageExternalStorage))
          Permission.manageExternalStorage,
        if (Permission.values.contains(Permission.mediaLibrary))
          Permission.mediaLibrary,
      ];
    }

    if (Platform.isIOS) {
      requiredPermissions = [
        Permission.photos,
        if (Permission.values.contains(Permission.mediaLibrary))
          Permission.mediaLibrary,
      ];
    }

    for (final permission in requiredPermissions) {
      final status = await permission.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        final result = await permission.request();
        if (!result.isGranted) return false;
      }
    }

    return true;
  }

  Future<Directory> _getRecordingsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final recordingsDir = Directory(
      '${appDir.path}/${AppConstants.recordingsDirectoryName}',
    );
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }
    return recordingsDir;
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
      final jsonString = json.encode(
        recordings.map((e) => e.toJson()).toList(),
      );
      await metadataFile.writeAsString(jsonString);
    } catch (e) {
      throw RecordingStorageException(details: e.toString());
    }
  }

  VideoPlayerController? get videoPlayerController => _videoPlayerController;
  ScreenRecorderController get screenRecorderController =>
      _screenRecorderController;
}
