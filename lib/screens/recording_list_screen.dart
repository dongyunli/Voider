import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../providers/recording_provider.dart';
import '../config/constants.dart';

// Format Duration to MM:SS
String _formatDuration(Duration? duration) {
  if (duration == null) return '00:00';
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

class RecordingListScreen extends StatelessWidget {
  const RecordingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordingProvider>(
      builder: (context, provider, child) {
        final files = provider.recordings;
        if (files.isEmpty) {
          return const Center(
            child: Text('暂无录音文件', style: TextStyle(color: Colors.grey)),
          );
        }
        
        return ListView.builder(
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
            final dateStr = DateFormat(AppConstants.displayDateFormat).format(file.createdAt);

            // 构建subtitle显示内容
            String subtitleText = dateStr;
            if (file.isPlaying && file.totalDuration != null) {
              // 显示播放时间：当前播放时长 / 文件总时长
              final currentTime = _formatDuration(file.playbackPosition);
              final totalTime = _formatDuration(file.totalDuration);
              subtitleText = '$currentTime / $totalTime';
            }

            return Card(
              child: ListTile(
                leading: const Icon(Icons.audiotrack),
                title: Text(file.name),
                subtitle: Text(subtitleText),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 播放/停止按钮
                    IconButton(
                      icon: file.isPlaying
                            ? const Icon(Icons.stop)
                            : const Icon(Icons.play_circle_outline),
                      onPressed: () => provider.playRecording(file.path),
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {
                        Share.shareXFiles([XFile(file.path)], text: '分享录音: ${file.name}');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('确认删除'),
                            content: Text('确定要删除 ${file.name} 吗？'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('取消'),
                              ),
                              TextButton(
                                onPressed: () {
                                  provider.deleteRecording(file.path);
                                  Navigator.pop(ctx);
                                },
                                child: const Text('删除', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
