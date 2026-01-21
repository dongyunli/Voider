import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recording_provider.dart';
import '../utils/time_formatter.dart';
import '../config/constants.dart';

class TimerDisplay extends StatelessWidget {
  const TimerDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordingProvider>(
      builder: (context, provider, child) {
        // 如果设定了限时，显示倒计时，否则显示正计时
        int secondsToShow = provider.elapsedSeconds;
        bool isCountdown = provider.selectedDurationLimit != AppConstants.unlimitedDuration;
        
        if (isCountdown) {
          int totalLimitSeconds = provider.selectedDurationLimit * 60;
          secondsToShow = totalLimitSeconds - provider.elapsedSeconds;
          if (secondsToShow < 0) secondsToShow = 0;
        }

        return Column(
          children: [
            Text(
              TimeFormatter.formatDuration(secondsToShow),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontFeatures: [const FontFeature.tabularFigures()], // 等宽数字，防止跳动
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isCountdown ? '剩余时间' : '录音时长',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        );
      },
    );
  }
}
