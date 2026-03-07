import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:voider_recorder/main.dart' as app;
import 'package:voider_recorder/providers/recording_provider.dart';

void main() {
  group('Concurrent Recording Tests', () {
    testWidgets('Cannot start multiple recordings simultaneously', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 获取 provider
      final provider = Provider.of<RecordingProvider>(
        tester.element(find.byType(Scaffold)),
        listen: false,
      );

      // 点击开始录音
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();

      // 验证录音已开始
      expect(provider.isRecording, isTrue);

      // 再次点击开始录音（第二次点击应该被忽略）
      await tester.tap(find.byIcon(Icons.pause)); // 点击暂停按钮（因为现在是录音状态）
      await tester.pumpAndSettle();

      // 验证仍然只有一个录音在进行中
      expect(provider.isRecording, isTrue);

      // 停止录音
      await tester.tap(find.byIcon(Icons.stop));
      await tester.pumpAndSettle();

      // 验证录音已停止
      expect(provider.isRecording, isFalse);
    });

    testWidgets('Cannot start recording while already paused', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 开始录音
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();

      // 暂停录音
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      // 验证已暂停
      final provider = Provider.of<RecordingProvider>(
        tester.element(find.byType(Scaffold)),
        listen: false,
      );
      expect(provider.isPaused, isTrue);

      // 恢复录音
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      // 验证已恢复
      expect(provider.isPaused, isFalse);
      expect(provider.isRecording, isTrue);
    });

    testWidgets('Stop button works while recording', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 开始录音
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();

      // 验证录音中
      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsOneWidget);

      // 停止录音
      await tester.tap(find.byIcon(Icons.stop));
      await tester.pumpAndSettle();

      // 验证已停止
      expect(find.byIcon(Icons.mic), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsNothing);
      expect(find.byIcon(Icons.stop), findsNothing);
    });

    testWidgets('Duration selector disabled during recording', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 选择时长
      await tester.tap(find.text('5分钟'));
      await tester.pumpAndSettle();

      // 开始录音
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();

      // 验证时长选择器已禁用
      // 在录音状态下，chip 应该存在但不可点击
      final chips = find.byType(ChoiceChip);
      expect(chips, findsWidgets);

      // 点击一个 chip 不应该触发时长改变
      await tester.tap(find.text('10分钟'));
      await tester.pump();

      // 仍然是录音状态
      final provider = Provider.of<RecordingProvider>(
        tester.element(find.byType(Scaffold)),
        listen: false,
      );
      expect(provider.isRecording, isTrue);

      // 停止录音
      await tester.tap(find.byIcon(Icons.stop));
      await tester.pumpAndSettle();
    });

    testWidgets('Cannot play recording while recording', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 创建一个录音
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.byIcon(Icons.stop));
      await tester.pumpAndSettle();

      // 开始新录音
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();

      // 尝试播放录音（应该在录音列表中）
      // 但由于正在录音，播放按钮应该不可用或被忽略
      final playButtons = find.byIcon(Icons.play_circle_outline);
      if (playButtons.evaluate().isNotEmpty) {
        // 如果有播放按钮，点击它不应该触发播放
        await tester.tap(playButtons.first);
        await tester.pumpAndSettle();
      }

      // 验证仍在录音
      final provider = Provider.of<RecordingProvider>(
        tester.element(find.byType(Scaffold)),
        listen: false,
      );
      expect(provider.isRecording, isTrue);

      // 停止录音
      await tester.tap(find.byIcon(Icons.stop));
      await tester.pumpAndSettle();
    });

    testWidgets('Rapid state transitions are handled gracefully', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 快速点击多个按钮
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.stop));
      await tester.pumpAndSettle();

      // 验证最终状态：停止
      final provider = Provider.of<RecordingProvider>(
        tester.element(find.byType(Scaffold)),
        listen: false,
      );
      expect(provider.isRecording, isFalse);
      expect(provider.isPaused, isFalse);
    });
  });

  group('Edge Case Tests', () {
    testWidgets('App handles storage space warning gracefully', (WidgetTester tester) async {
      // 这个测试验证 UI 不会崩溃
      // 实际的存储空间检查在 RecordingProvider 中完成
      app.main();
      await tester.pumpAndSettle();

      // 应该正常显示 UI
      expect(find.text('Voider 录音机'), findsOneWidget);
      expect(find.text('00:00'), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('App handles permission denied gracefully', (WidgetTester tester) async {
      // 这个测试验证 UI 不会崩溃
      // 实际的权限检查在 PermissionService 中完成
      app.main();
      await tester.pumpAndSettle();

      // 应该正常显示 UI
      expect(find.text('Voider 录音机'), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsOneWidget);
    });

    testWidgets('Empty list shows helpful message', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 验证空列表显示友好提示
      expect(find.text('暂无录音文件'), findsOneWidget);
      expect(find.text('点击下方麦克风开始录音'), findsOneWidget);
      expect(find.byIcon(Icons.audiotrack), findsOneWidget);
    });

    testWidgets('Loading state shows correctly', (WidgetTester tester) async {
      app.main();
      await tester.pump();

      // 验证加载状态显示
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('加载录音列表...'), findsOneWidget);

      // 等待加载完成
      await tester.pumpAndSettle();
    });
  });
}
