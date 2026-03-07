import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../providers/recording_provider.dart';
import '../models/recording_file.dart';
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
    return Selector<RecordingProvider, List<RecordingFile>>(
      selector: (context, provider) => provider.recordings,
      builder: (context, files, child) {
        // 显示加载状态
        final provider = context.read<RecordingProvider>();
        if (provider.isInitializing) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('加载录音列表...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        // 空列表状态
        if (files.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.audiotrack, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('暂无录音文件', style: TextStyle(color: Colors.grey)),
                SizedBox(height: 8),
                Text('点击下方麦克风开始录音', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          );
        }
        
        return ListView.builder(
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
            return _RecordingListItem(file: file);
          },
        );
      },
    );
  }
}

// Separate widget for each list item to localize rebuilds
class _RecordingListItem extends StatelessWidget {
  final RecordingFile file;

  const _RecordingListItem({required this.file});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat(AppConstants.displayDateFormat).format(file.createdAt);
    final provider = context.read<RecordingProvider>();

    return Card(
      child: ListTile(
        leading: const Icon(Icons.audiotrack),
        title: Text(file.name),
        subtitle: Consumer<RecordingProvider>(
          builder: (context, provider, child) {
            // Only rebuild subtitle when playback state changes
            String subtitleText = dateStr;
            final playbackState = provider.getPlaybackState(file.path);
            if (playbackState != null && playbackState.isPlaying && playbackState.totalDuration != null) {
              final currentTime = _formatDuration(playbackState.currentPosition);
              final totalTime = _formatDuration(playbackState.totalDuration);
              subtitleText = '$currentTime / $totalTime';
            }
            return Text(subtitleText);
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 播放/停止按钮
            Consumer<RecordingProvider>(
              builder: (context, provider, child) {
                final playbackState = provider.getPlaybackState(file.path);
                return IconButton(
                  icon: playbackState?.isPlaying == true
                        ? const Icon(Icons.stop)
                        : const Icon(Icons.play_circle_outline),
                  onPressed: () => provider.playRecording(file.path),
                );
              },
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
  }
}
