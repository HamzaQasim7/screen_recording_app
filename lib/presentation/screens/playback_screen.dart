import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_formater.dart';
import '../../core/utils/size_config.dart';
import '../../domain/entities/recording.dart';
import '../../widgets/recording_list_item.dart';
import '../view_models/play_back_view_model.dart';
import '../view_models/recording_provider.dart';

class PlaybackScreen extends StatefulWidget {
  const PlaybackScreen({super.key});

  @override
  State<PlaybackScreen> createState() => _PlaybackScreenState();
}

class _PlaybackScreenState extends State<PlaybackScreen> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      SizeConfig().init(context);
      _loadRecordings();
      _isInitialized = true;
    }
  }

  void _loadRecordings() {
    final provider = Provider.of<RecordingProvider>(context, listen: false);
    provider.loadRecordings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recordings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecordings,
            tooltip: 'Refresh recordings',
          ),
        ],
      ),
      body: Consumer<RecordingProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.playbackErrorMessage != null) {
            return _buildErrorView(provider);
          }

          if (provider.recordings.isEmpty) {
            return _buildEmptyView();
          }

          return _buildRecordingsList(provider);
        },
      ),
    );
  }

  Widget _buildErrorView(RecordingProvider provider) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 5,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Error loading recordings',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              provider.playbackErrorMessage!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                provider.resetPlaybackError();
                _loadRecordings();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 5,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No Recordings Yet',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Start recording your screen to see the list here.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.fiber_manual_record),
              label: const Text('Record Screen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingsList(RecordingProvider provider) {
    // Sort recordings by date (newest first)
    final sortedRecordings = List<Recording>.from(provider.recordings)
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadRecordings();
      },
      child: ListView.separated(
        padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
        itemCount: sortedRecordings.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final recording = sortedRecordings[index];
          final isPlaying =
              provider.currentPlayingId == recording.id &&
              provider.playbackState == PlaybackState.playing;

          return RecordingListItem(
            recording: recording,
            isPlaying: isPlaying,
            onPlay: () => _playRecording(provider, recording.id),
            onDelete:
                () => _showDeleteConfirmation(context, provider, recording),
          );
        },
      ),
    );
  }

  void _playRecording(RecordingProvider provider, String recordingId) async {
    try {
      await provider.playRecording(recordingId);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to play recording: $e')));
      }
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    RecordingProvider provider,
    Recording recording,
  ) async {
    final dateFormatted = DateFormatter.formatDateTimeForDisplay(
      recording.recordedAt,
    );
    final durationFormatted = DateFormatter.formatDuration(
      recording.durationInSeconds,
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Recording'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this recording?'),
                const SizedBox(height: 16),
                Text('Date: $dateFormatted'),
                Text('Duration: $durationFormatted'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await provider.deleteRecording(recording.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recording deleted')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
