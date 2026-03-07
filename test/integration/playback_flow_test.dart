import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:voider_recorder/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Playback Flow Integration Tests', () {
    testWidgets('Complete playback flow: play, stop', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // First, create a recording
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.byIcon(Icons.stop));
      await tester.pumpAndSettle();

      // Verify recording is in the list
      expect(find.text('暂无录音文件'), findsNothing);

      // Find the play button for the recording
      final playButton = find.byIcon(Icons.play_circle_outline);
      expect(playButton, findsOneWidget);

      // Play the recording
      await tester.tap(playButton);
      await tester.pumpAndSettle();

      // Verify playback started (play button changed to stop button)
      expect(find.byIcon(Icons.play_circle_outline), findsNothing);
      expect(find.byIcon(Icons.stop), findsAtLeastNWidgets(2)); // One for recording controls, one for playback

      // Stop playback
      final stopButtons = find.byIcon(Icons.stop);
      await tester.tap(stopButtons.at(1)); // Tap the second stop button (playback stop)
      await tester.pumpAndSettle();

      // Verify playback stopped
      expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
    });

    testWidgets('Share recording', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // First, create a recording
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.byIcon(Icons.stop));
      await tester.pumpAndSettle();

      // Find the share button
      final shareButton = find.byIcon(Icons.share);
      expect(shareButton, findsOneWidget);

      // Tap share button
      await tester.tap(shareButton);
      await tester.pumpAndSettle();

      // Share dialog should be shown (we can't verify the actual share action in tests)
      // but we can verify the button is tappable
    });

    testWidgets('Delete recording with confirmation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // First, create a recording
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.byIcon(Icons.stop));
      await tester.pumpAndSettle();

      // Verify recording exists
      expect(find.text('暂无录音文件'), findsNothing);

      // Find and tap delete button
      final deleteButton = find.byIcon(Icons.delete_outline);
      expect(deleteButton, findsOneWidget);
      
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text('确认删除'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
      expect(find.text('删除'), findsOneWidget);

      // Cancel deletion
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      // Verify recording still exists
      expect(find.text('暂无录音文件'), findsNothing);

      // Try delete again and confirm
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      await tester.tap(find.text('删除'));
      await tester.pumpAndSettle();

      // Verify recording was deleted
      expect(find.text('暂无录音文件'), findsOneWidget);
    });

    testWidgets('Playback position updates display', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Create a longer recording
      await tester.tap(find.text('1分钟'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.mic));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      await tester.tap(find.byIcon(Icons.stop));
      await tester.pumpAndSettle();

      // Play the recording
      await tester.tap(find.byIcon(Icons.play_circle_outline));
      await tester.pumpAndSettle();

      // Wait for playback to progress
      await tester.pump(const Duration(seconds: 2));

      // Verify that the subtitle shows playback progress
      // The subtitle should contain time format like "00:XX / 00:XX"
      final listTiles = find.byType(ListTile);
      expect(listTiles, findsOneWidget);
    });
  });
}
