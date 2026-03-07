import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:voider_recorder/main.dart' as app;
import 'package:voider_recorder/providers/recording_provider.dart';
import 'package:provider/provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Recording Flow Integration Tests', () {
    testWidgets('Complete recording flow: start, record, stop', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Voider 录音机'), findsOneWidget);
      expect(find.text('00:00'), findsOneWidget);
      expect(find.text('录音时长'), findsOneWidget);
      expect(find.byIcon(Icons.mic), findsOneWidget);

      // Start recording
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();

      // Verify recording started
      final provider = Provider.of<RecordingProvider>(tester.element(find.byType(Scaffold)), listen: false);
      expect(provider.isRecording, isTrue);

      // Verify UI shows pause and stop buttons
      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsOneWidget);
      expect(find.text('录音时长'), findsOneWidget);

      // Wait a bit to simulate recording
      await tester.pump(const Duration(seconds: 2));

      // Pause recording
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pumpAndSettle();

      // Verify paused state
      expect(provider.isPaused, isTrue);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // Resume recording
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pumpAndSettle();

      // Verify resumed state
      expect(provider.isPaused, isFalse);
      expect(find.byIcon(Icons.pause), findsOneWidget);

      // Stop recording
      await tester.tap(find.byIcon(Icons.stop));
      await tester.pumpAndSettle();

      // Verify recording stopped
      expect(provider.isRecording, isFalse);
      expect(find.byIcon(Icons.mic), findsOneWidget);

      // Verify recording was added to list
      expect(find.text('暂无录音文件'), findsNothing);
    });

    testWidgets('Recording with duration limit', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Select 1 minute duration limit
      await tester.tap(find.text('1分钟'));
      await tester.pumpAndSettle();

      // Verify duration changed
      expect(find.text('剩余时间'), findsOneWidget);
      expect(find.text('01:00'), findsOneWidget);

      // Start recording
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();

      // Verify countdown is displayed
      expect(find.text('剩余时间'), findsOneWidget);

      // Stop recording
      await tester.tap(find.byIcon(Icons.stop));
      await tester.pumpAndSettle();
    });

    testWidgets('Switch between unlimited and timed recording', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Initially unlimited
      expect(find.text('录音时长'), findsOneWidget);

      // Switch to 5 minutes
      await tester.tap(find.text('5分钟'));
      await tester.pumpAndSettle();
      expect(find.text('剩余时间'), findsOneWidget);

      // Switch back to unlimited
      await tester.tap(find.text('不限时'));
      await tester.pumpAndSettle();
      expect(find.text('录音时长'), findsOneWidget);
    });

    testWidgets('Duration selector disabled during recording', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Start recording
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();

      // Try to change duration (should be disabled)
      final fiveMinuteChip = find.ancestor(
        of: find.text('5分钟'),
        matching: find.byType(ChoiceChip),
      );
      
      // The chip should still be visible but not interactive
      expect(fiveMinuteChip, findsOneWidget);
      
      // Tap should not change anything
      await tester.tap(fiveMinuteChip);
      await tester.pump();
      
      // Recording should still be active
      final provider = Provider.of<RecordingProvider>(tester.element(find.byType(Scaffold)), listen: false);
      expect(provider.isRecording, isTrue);

      // Stop recording
      await tester.tap(find.byIcon(Icons.stop));
      await tester.pumpAndSettle();
    });
  });
}
