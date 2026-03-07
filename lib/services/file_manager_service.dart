import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../config/constants.dart';
import '../models/recording_file.dart';

class FileManagerService {
  final Logger _logger = Logger();  // ✅ 添加 Logger
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

    // 验证文件名格式并移除危险字符
    final safeTimestamp = timestamp.replaceAll(RegExp(r'[<>:"|?*|\\|/]'), '_');
    final sanitizedName = safeTimestamp.substring(0, safeTimestamp.length > 100 ? 100 : safeTimestamp.length);

    // 使用扩展名常量
    return '$dirPath/rec_$sanitizedName${AppConstants.recordingFileExtension}';  // ✅ 使用常量
  }

  Future<List<RecordingFile>> getRecordings() async {
    final dirPath = await getRecordingDirectoryPath();
    final dir = Directory(dirPath);
    List<RecordingFile> files = [];

    if (await dir.exists()) {
      try {
        // ✅ 使用异步 list() 而非 listSync()
        await for (final entity in dir.list()) {
          try {
            if (entity is File && entity.path.endsWith('.aac')) {
              final stat = await entity.stat();
              final name = entity.path.split(Platform.pathSeparator).last;
              files.add(RecordingFile(
                path: entity.path,
                name: name,
                createdAt: stat.changed,
                size: stat.size,
              ));
            }
          } catch (e) {
            _logger.w("Error processing file ${entity.path}: $e");
          }
        }
      } catch (e) {
        _logger.e("Error listing recordings directory: $e");
        rethrow;
      }
    }
    // 按时间倒序排列
    files.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return files;
  }
  
  Future<void> deleteFile(String path) async {
    try {
      // 获取录音目录路径
      final recordingsDir = await getRecordingDirectoryPath();

      // 验证文件路径是否在录音目录内
      final normalizedPath = File(path).absolute.path;
      final normalizedDir = Directory(recordingsDir).absolute.path;

      if (!normalizedPath.startsWith(normalizedDir)) {
        _logger.e("Security: Attempt to delete file outside recordings directory: $path");
        throw ArgumentError("Cannot delete file outside recordings directory");
      }

      // 验证文件扩展名
      final validExtensions = ['.aac', '.m4a'];
      if (!validExtensions.any((ext) => normalizedPath.endsWith(ext))) {
        _logger.w("Invalid file extension attempted: $path");
        throw ArgumentError("Invalid file extension");
      }

      // 执行删除
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        _logger.i("File deleted successfully: $path");
      } else {
        _logger.w("File does not exist: $path");
      }
    } catch (e) {
      _logger.e("Error deleting file: $path, error: $e");
      rethrow;
    }
  }
}
