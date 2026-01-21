import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../config/constants.dart';
import '../models/recording_file.dart';

class FileManagerService {
  Future<String> getRecordingDirectoryPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final recordingsDir = Directory('${directory.path}/recordings');
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }
    return recordingsDir.path;
  }

  Future<String> generateFilePath() async {
    final dirPath = await getRecordingDirectoryPath();
    final timestamp = DateFormat(AppConstants.filenameDateFormat).format(DateTime.now());
    // 使用 .aac 扩展名，flutter_sound 支持的标准 AAC 格式
    return '$dirPath/rec_$timestamp.aac';
  }

  Future<List<RecordingFile>> getRecordings() async {
    final dirPath = await getRecordingDirectoryPath();
    final dir = Directory(dirPath);
    List<RecordingFile> files = [];

    if (await dir.exists()) {
      final List<FileSystemEntity> entities = dir.listSync();
      for (var entity in entities) {
        if (entity is File && entity.path.endsWith('.aac')) {
          final stat = await entity.stat();
          final name = entity.path.split(Platform.pathSeparator).last;
          // 注意：实际应用中可能需要读取元数据获取准确时长，
          // 这里简化处理，或在录音结束时保存元数据到数据库/文件名
          files.add(RecordingFile(
            path: entity.path,
            name: name,
            createdAt: stat.changed,
            size: stat.size,
          ));
        }
      }
    }
    // 按时间倒序排列
    files.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return files;
  }
  
  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
