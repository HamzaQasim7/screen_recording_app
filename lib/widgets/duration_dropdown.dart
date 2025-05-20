import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';

class DurationDropdown extends StatelessWidget {
  final int selectedDuration;
  final Function(int) onDurationChanged;
  final bool isEnabled;

  const DurationDropdown({
    super.key,
    required this.selectedDuration,
    required this.onDurationChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recording Duration:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              value: selectedDuration,
              onChanged: isEnabled
                  ? (int? newValue) {
                      if (newValue != null) {
                        onDurationChanged(newValue);
                      }
                    }
                  : null,
              items: AppConstants.recordingDurations.map<DropdownMenuItem<int>>((
                int value,
              ) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(_formatDuration(value)),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds seconds';
    } else {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return remainingSeconds > 0
          ? '$minutes minute${minutes > 1 ? 's' : ''} $remainingSeconds second${remainingSeconds > 1 ? 's' : ''}'
          : '$minutes minute${minutes > 1 ? 's' : ''}';
    }
  }
}
