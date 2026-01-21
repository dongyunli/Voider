import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recording_provider.dart';

class RecordingControls extends StatelessWidget {
  const RecordingControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordingProvider>(
      builder: (context, provider, child) {
        if (provider.isRecording) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 暂停/继续按钮
              FloatingActionButton.large(
                onPressed: () {
                  if (provider.isPaused) {
                    provider.resumeRecording();
                  } else {
                    provider.pauseRecording();
                  }
                },
                backgroundColor: Colors.orange,
                child: Icon(provider.isPaused ? Icons.play_arrow : Icons.pause),
              ),
              const SizedBox(width: 32),
              // 停止按钮
              FloatingActionButton.large(
                onPressed: () => provider.stopRecording(),
                backgroundColor: Colors.red,
                child: const Icon(Icons.stop),
              ),
            ],
          );
        } else {
          // 开始录音按钮
          return FloatingActionButton.large(
            onPressed: () => provider.startRecording(),
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.mic, size: 48),
          );
        }
      },
    );
  }
}
