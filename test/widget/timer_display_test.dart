import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:voider_recorder/widgets/timer_display.dart';
import 'package:voider_recorder/providers/recording_provider.dart';
import 'package:voider_recorder/config/constants.dart';
import 'package:voider_recorder/models/recording_file.dart';

class MockRecordingProvider extends ChangeNotifier implements RecordingProvider {
  @override
  final ValueNotifier<int> elapsedSecondsNotifier = ValueNotifier(0);

  @override
  int get elapsedSeconds => elapsedSecondsNotifier.value;

  @override
  int selectedDurationLimit = AppConstants.unlimitedDuration;

  void setElapsedSeconds(int seconds) {
    elapsedSecondsNotifier.value = seconds;
  }

  @override
  bool get isRecording => false;

  @override
  bool get isPaused => false;

  @override
  bool get isInitializing => false;

  @override
  bool get isPlaying => false;

  @override
  List<RecordingFile> get recordings => [];

  @override
  Future<void> loadRecordings() async {}

  @override
  Future<void> startRecording() async {}

  @override
  Future<void> stopRecording() async {}

  @override
  Future<void> pauseRecording() async {}

  @override
  Future<void> resumeRecording() async {}

  @override
  Future<void> setDurationLimit(int minutes) async {}

  @override
  Future<void> playRecording(String path) async {}

  @override
  Future<void> stopPlayback() async {}

  @override
  Future<void> deleteRecording(String path) async {}

  @override
  PlaybackState? getPlaybackState(String path) => null;

  @override
  void dispose() {
    elapsedSecondsNotifier.dispose();
    super.dispose();
  }
}

void main() {
  late MockRecordingProvider mockProvider;

  setUp(() {
    mockProvider = MockRecordingProvider();
  });

  tearDown(() {
    mockProvider.dispose();
  });

  testWidgets('TimerDisplay displays elapsed time correctly', (WidgetTester tester) async {
    mockProvider.setElapsedSeconds(65);
    
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<RecordingProvider>.value(
          value: mockProvider,
          child: const TimerDisplay(),
        ),
      ),
    );

    expect(find.text('01:05'), findsOneWidget);
    expect(find.text('录音时长'), findsOneWidget);
  });

  testWidgets('TimerDisplay displays countdown when duration limit is set', (WidgetTester tester) async {
    mockProvider.selectedDurationLimit = 5; // 5 minutes
    mockProvider.setElapsedSeconds(120); // 2 minutes elapsed, should show 3 minutes remaining
    
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<RecordingProvider>.value(
          value: mockProvider,
          child: const TimerDisplay(),
        ),
      ),
    );

    expect(find.text('03:00'), findsOneWidget);
    expect(find.text('剩余时间'), findsOneWidget);
  });

  testWidgets('TimerDisplay updates when elapsedSeconds changes', (WidgetTester tester) async {
    mockProvider.setElapsedSeconds(0);
    
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<RecordingProvider>.value(
          value: mockProvider,
          child: const TimerDisplay(),
        ),
      ),
    );

    expect(find.text('00:00'), findsOneWidget);

    // Update elapsed seconds
    mockProvider.setElapsedSeconds(125);
    await tester.pump();

    expect(find.text('02:05'), findsOneWidget);
  });

  testWidgets('TimerDisplay countdown shows 00:00 when time limit is reached', (WidgetTester tester) async {
    mockProvider.selectedDurationLimit = 2; // 2 minutes
    mockProvider.setElapsedSeconds(150); // 2.5 minutes elapsed
    
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<RecordingProvider>.value(
          value: mockProvider,
          child: const TimerDisplay(),
        ),
      ),
    );

    expect(find.text('00:00'), findsOneWidget);
  });

  testWidgets('TimerDisplay uses tabular figures to prevent jitter', (WidgetTester tester) async {
    mockProvider.setElapsedSeconds(65);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<RecordingProvider>.value(
          value: mockProvider,
          child: const TimerDisplay(),
        ),
      ),
    );

    final textFinder = find.text('01:05');
    expect(textFinder, findsOneWidget);

    final textWidget = tester.widget<Text>(textFinder);
    expect(textWidget.style?.fontFeatures, isNotNull);
    expect(textWidget.style?.fontFeatures?.any((feature) => feature.feature == 'tnum'), isTrue);
  });
}
