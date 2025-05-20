import 'package:flutter/foundation.dart';

import '../../domain/entities/recording.dart';
import '../../domain/usecases/save_recording.dart';

enum RecordingState { idle, recording, error }

class RecordingViewModel with ChangeNotifier {
  final SaveRecording saveRecordingUseCase;

  RecordingViewModel({required this.saveRecordingUseCase});

  RecordingState _recordingState = RecordingState.idle;
  Recording? _currentRecording;
  String? _errorMessage;
  int _selectedDurationInSeconds = 30; // Default duration

  RecordingState get recordingState => _recordingState;
  Recording? get currentRecording => _currentRecording;
  String? get errorMessage => _errorMessage;
  int get selectedDurationInSeconds => _selectedDurationInSeconds;

  void setSelectedDuration(int seconds) {
    _selectedDurationInSeconds = seconds;
    notifyListeners();
  }

  bool get isRecording => _recordingState == RecordingState.recording;
  Future<void> startRecording() async {
    if (_recordingState == RecordingState.recording) return;

    _recordingState = RecordingState.recording;
    _errorMessage = null;
    notifyListeners();

    final result = await saveRecordingUseCase(
      durationInSeconds: _selectedDurationInSeconds,
      onRecordingStatus: (isRecording) {
        _recordingState =
            isRecording ? RecordingState.recording : RecordingState.idle;
        notifyListeners();
      },
    );

    result.fold(
      (failure) {
        _recordingState = RecordingState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (recording) {
        _currentRecording = recording;
        // keep state as 'recording' since stop happens later
      },
    );
  }

  Future<void> startRecordings() async {
    if (_recordingState == RecordingState.recording) {
      return;
    }
    (recording) {
      if (recording == null) {
        _recordingState = RecordingState.error;
        _errorMessage = 'Failed to start recording: No valid data received.';
        notifyListeners();
        return;
      }
      _currentRecording = recording;
    };
    _recordingState = RecordingState.recording;
    _errorMessage = null;
    notifyListeners();

    final result = await saveRecordingUseCase(
      durationInSeconds: _selectedDurationInSeconds,
      onRecordingStatus: (isRecording) {
        if (!isRecording) {
          _recordingState = RecordingState.idle;
          notifyListeners();
        }
      },
    );

    result.fold(
      (failure) {
        _recordingState = RecordingState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (recording) {
        _currentRecording = recording;
        // Do not change state here, as the recording is still in progress
      },
    );
  }

  Future<void> stopRecording() async {
    if (_recordingState != RecordingState.recording) {
      return;
    }

    final result = await saveRecordingUseCase.stopRecording();

    result.fold(
      (failure) {
        _recordingState = RecordingState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (recording) {
        if (recording == null) {
          _recordingState = RecordingState.error;
          _errorMessage = 'Export failed: No frames to export.';
          notifyListeners();
          return;
        }

        _currentRecording = recording;
        _recordingState = RecordingState.idle;
        notifyListeners();
      },
    );
  }

  bool isCurrentlyRecording() {
    return saveRecordingUseCase.isRecording();
  }

  void resetError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
