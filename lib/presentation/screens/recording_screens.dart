import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/size_config.dart';
import '../../widgets/duration_dropdown.dart';
import '../../widgets/recording_button.dart';
import '../view_models/recording_provider.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      SizeConfig().init(context);
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.pushNamed(context, '/playback');
            },
            tooltip: 'View Recordings',
          ),
        ],
      ),
      body: Consumer<RecordingProvider>(
        builder: (context, provider, _) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recording info section
                  _buildRecordingInfoSection(provider),
                  SizedBox(height: SizeConfig.blockSizeVertical * 4),
                  // Duration selection dropdown
                  DurationDropdown(
                    selectedDuration: provider.selectedDurationInSeconds,
                    onDurationChanged: provider.setSelectedDuration,
                    isEnabled: !provider.isRecording,
                  ),
                  SizedBox(height: SizeConfig.blockSizeVertical * 4),

                  // Recording button
                  RecordingButton(
                    isRecording: provider.isRecording,
                    onStartRecording: () => _startRecording(provider),
                    onStopRecording: () => _stopRecording(provider),
                  ),
                  SizedBox(height: SizeConfig.blockSizeVertical * 4),

                  // Status and error message section
                  _buildStatusSection(provider),

                  const Spacer(),

                  // View recordings button
                  if (!provider.isRecording)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.video_library),
                        label: const Text('View Recordings'),
                        onPressed: () {
                          Navigator.pushNamed(context, '/playback');
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecordingInfoSection(RecordingProvider provider) {
    if (!provider.isRecording) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Record Your Screen',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a duration and press Start Recording to capture your screen activity.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.fiber_manual_record, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recording in progress',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Duration: ${provider.selectedDurationInSeconds} seconds',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildStatusSection(RecordingProvider provider) {
    if (provider.recordingErrorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Error',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(provider.recordingErrorMessage!),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: provider.resetRecordingError,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: const Size(0, 0),
                    ),
                    child: const Text('Dismiss'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _startRecording(RecordingProvider provider) async {
    if (provider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recording provider is not initialized')),
      );
      return;
    }

    try {
      await provider.startRecording();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start recording: $e')),
        );
      }
    }
  }

  void _stopRecording(RecordingProvider provider) async {
    try {
      await provider.stopRecording();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to stop recording: $e')));
      }
    }
  }
}
