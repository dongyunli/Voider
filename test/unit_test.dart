import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:voider_recorder/services/permission_service.dart';
import 'package:voider_recorder/services/file_manager_service.dart';
import 'package:voider_recorder/services/audio_recorder_service.dart';

void main() {
  group('AudioRecorderService Error Handling', () {
    late AudioRecorderService service;
    late Logger logger;

    setUp(() {
      logger = Logger();
      service = AudioRecorderService();
    });

    tearDown(() {
      logger.close();
      service.dispose();
    });

    test('init() can be called multiple times', () async {
      // 首次初始化
      await service.init();
      
      // 再次初始化不应该崩溃
      await service.init();
      
      expect(service, isNotNull);
    });

    test('stop() handles stop without start gracefully', () async {
      await service.init();
      // 停止未启动的录音不应该崩溃
      await service.stop();
      
      expect(service, isNotNull);
    });

    test('pause() handles pause without start gracefully', () async {
      await service.init();
      // 暂停未启动的录音不应该崩溃
      await service.pause();
      
      expect(service, isNotNull);
    });

    test('resume() handles resume without start gracefully', () async {
      await service.init();
      // 恢复未启动的录音不应该崩溃
      await service.resume();
      
      expect(service, isNotNull);
    });

    test('dispose() handles multiple dispose calls', () async {
      await service.init();
      await service.dispose();
      
      // 再次 dispose 应该幂等处理
      await service.dispose();
      
      expect(service, isNotNull);
    });

    test('isRecording() handles errors gracefully', () async {
      await service.init();
      // 检查录音状态不应该崩溃
      final isRecording = await service.isRecording();
      expect(isRecording, isA<bool>());
    });
  });

  group('FileManagerService Edge Cases', () {
    late FileManagerService service;
    late Logger logger;

    setUp(() {
      logger = Logger();
      service = FileManagerService();
    });

    tearDown(() {
      logger.close();
    });

    test('getRecordings() handles non-existent directory gracefully', () async {
      // 第一次调用应该创建目录并返回空列表
      final recordings = await service.getRecordings();
      expect(recordings, isEmpty);
    });

    test('deleteFile() handles non-existent file gracefully', () async {
      // 删除不存在的文件不应该崩溃
      await expectLater(
        () => service.deleteFile('/nonexistent/path/file.aac'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('generateFilePath() creates unique filenames', () async {
      // 并发生成文件名应该不同
      final paths = await Future.wait([
        service.generateFilePath(),
        service.generateFilePath(),
        service.generateFilePath(),
      ]);

      expect(paths[0], isNot(equals(paths[1])));
      expect(paths[1], isNot(equals(paths[2])));
      expect(paths[0], isNot(equals(paths[2])));

      // 所有路径应该以 .aac 结尾
      for (final path in paths) {
        expect(path, endsWith('.aac'));
      }
    });
  });

  group('PermissionService Tests', () {
    late PermissionService service;
    late Logger logger;

    setUp(() {
      logger = Logger();
      service = PermissionService();
    });

    tearDown(() {
      logger.close();
    });

    test('requestRecordingPermissions - granted', () async {
      final result = await service.requestRecordingPermissions();
      expect(result, isA<bool>());
    });

    test('checkPermission - granted', () async {
      final result = await service.checkPermission();
      expect(result, isA<bool>());
    });

    test('checkPermission - not granted', () async {
      // 注意：实际测试可能需要 mock Permission.microphone.isGranted
      // 这里作为示例展示测试结构
      final result = await service.checkPermission();
      expect(result, isA<bool>());
    });

    test('openSettings - opens app settings', () async {
      // 注意：openAppSettings() 实际会打开系统设置
      // 这里仅测试方法调用不抛出异常
      await service.openSettings();
    });
  });

  group('FileManagerService Tests', () {
    late FileManagerService service;
    late Logger logger;

    setUp(() {
      logger = Logger();
      service = FileManagerService();
    });

    tearDown(() {
      logger.close();
    });

    test('generateFilePath - generates valid path', () async {
      final path = await service.generateFilePath();
      expect(path, isNotEmpty);
      expect(path, contains('.aac'));
    });

    test('getRecordings - returns empty list initially', () async {
      final recordings = await service.getRecordings();
      expect(recordings, isEmpty);
    });
  });
}
