import 'package:flutter/foundation.dart';
import 'package:job_test/presentation/view_models/play_back_view_model.dart';
import 'package:job_test/presentation/view_models/recording_view_model.dart';

import '../../domain/entities/recording.dart';

class RecordingProvider with ChangeNotifier {
  final RecordingViewModel recordingViewModel;
  final PlaybackViewModel playbackViewModel;

  RecordingProvider({
    required this.recordingViewModel,
    required this.playbackViewModel,
  });

  int _selectedDurationInSeconds = 30; // Default duration

  // Recording functionality
  RecordingState get recordingState => recordingViewModel.recordingState;
  Recording? get currentRecording => recordingViewModel.currentRecording;
  String? get recordingErrorMessage => recordingViewModel.errorMessage;
  int get selectedDurationInSeconds => _selectedDurationInSeconds;
  bool get isRecording => recordingViewModel.isRecording;

  void setSelectedDuration(int duration) {
    _selectedDurationInSeconds = duration;
    notifyListeners(); // Ensure this is called to update the UI
  }

  Future<void> startRecording() async {
    await recordingViewModel.startRecording();
  }

  Future<void> stopRecording() async {
    await recordingViewModel.stopRecording();
    // Refresh recordings list when recording stops
    await playbackViewModel.loadRecordings();
  }

  bool isCurrentlyRecording() {
    return recordingViewModel.isCurrentlyRecording();
  }

  void resetRecordingError() {
    recordingViewModel.resetError();
  }

  // Playback functionality
  List<Recording> get recordings => playbackViewModel.recordings;
  PlaybackState get playbackState => playbackViewModel.playbackState;
  String? get currentPlayingId => playbackViewModel.currentPlayingId;
  String? get playbackErrorMessage => playbackViewModel.errorMessage;
  bool get isLoading => playbackViewModel.isLoading;

  Future<void> loadRecordings() async {
    await playbackViewModel.loadRecordings();
  }

  Future<void> playRecording(String recordingId) async {
    await playbackViewModel.playRecording(recordingId);
  }

  Future<void> deleteRecording(String recordingId) async {
    await playbackViewModel.deleteRecording(recordingId);
  }

  void stopPlayback() {
    playbackViewModel.stopPlayback();
  }

  void resetPlaybackError() {
    playbackViewModel.resetError();
  }
}
