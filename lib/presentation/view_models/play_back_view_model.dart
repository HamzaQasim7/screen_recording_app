import 'package:flutter/foundation.dart';

import '../../domain/entities/recording.dart';
import '../../domain/usecases/get_all_recording.dart';
import '../../domain/usecases/play_recording.dart';

enum PlaybackState { idle, loading, playing, error }

class PlaybackViewModel with ChangeNotifier {
  final GetAllRecordings getAllRecordingsUseCase;
  final PlayRecording playRecordingUseCase;

  PlaybackViewModel({
    required this.getAllRecordingsUseCase,
    required this.playRecordingUseCase,
  });

  List<Recording> _recordings = [];
  PlaybackState _playbackState = PlaybackState.idle;
  String? _currentPlayingId;
  String? _errorMessage;
  bool _isLoading = false;

  List<Recording> get recordings => _recordings;
  PlaybackState get playbackState => _playbackState;
  String? get currentPlayingId => _currentPlayingId;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> loadRecordings() async {
    _isLoading = true;
    notifyListeners();

    final result = await getAllRecordingsUseCase();

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (recordings) {
        _recordings = recordings;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
    );
  }

  Future<void> playRecording(String recordingId) async {
    if (_playbackState == PlaybackState.playing &&
        _currentPlayingId == recordingId) {
      return;
    }

    _playbackState = PlaybackState.loading;
    _currentPlayingId = recordingId;
    _errorMessage = null;
    notifyListeners();

    final result = await playRecordingUseCase(recordingId);

    result.fold(
      (failure) {
        _playbackState = PlaybackState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (_) {
        _playbackState = PlaybackState.playing;
        notifyListeners();
      },
    );
  }

  Future<void> deleteRecording(String recordingId) async {
    _isLoading = true;
    notifyListeners();

    final result = await playRecordingUseCase.deleteRecording(recordingId);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (deleted) {
        if (deleted) {
          _recordings.removeWhere((recording) => recording.id == recordingId);

          if (_currentPlayingId == recordingId) {
            _currentPlayingId = null;
            _playbackState = PlaybackState.idle;
          }
        }

        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void stopPlayback() {
    if (_playbackState == PlaybackState.playing) {
      _playbackState = PlaybackState.idle;
      _currentPlayingId = null;
      notifyListeners();
    }
  }

  void resetError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
