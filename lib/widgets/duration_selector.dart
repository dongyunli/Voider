import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recording_provider.dart';
import '../config/constants.dart';

class DurationSelector extends StatelessWidget {
  const DurationSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordingProvider>(
      builder: (context, provider, child) {
        // 如果正在录音，禁用选择
        final isRecording = provider.isRecording;
        
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildOption(context, provider, AppConstants.unlimitedDuration, '不限时', isRecording),
              ...AppConstants.recordingDurations.map((min) {
                return _buildOption(context, provider, min, '$min分钟', isRecording);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption(BuildContext context, RecordingProvider provider, int value, String label, bool isDisabled) {
    final isSelected = provider.selectedDurationLimit == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: isDisabled ? null : (selected) {
          if (selected) {
            provider.setDurationLimit(value);
          }
        },
      ),
    );
  }
}
