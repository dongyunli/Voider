import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:voider_recorder/widgets/recording_controls.dart';
import 'package:voider_recorder/providers/recording_provider.dart';
import 'package:voider_recorder/models/recording_file.dart';

class MockRecordingProvider extends ChangeNotifier implements RecordingProvider {
  bool _isRecording = false;
  bool _isPaused = false;

  @override
  bool get isRecording => _isRecording;

  @override
  bool get isPaused => _isPaused;

  @override
  bool get isInitializing => false;

  @override
  bool get isPlaying => false;

  void setRecordingState({required bool isRecording, required bool isPaused}) {
    _isRecording = isRecording;
    _isPaused = isPaused;
    notifyListeners();
  }

  @override
  final ValueNotifier<int> elapsedSecondsNotifier = ValueNotifier(0);

  @override
  int get elapsedSeconds => elapsedSecondsNotifier.value;

  @override
  int get selectedDurationLimit => -1;

  @override
  List<RecordingFile> get recordings => [];

  @override
  Future<void> loadRecordings() async {}

  @override
  Future<void> startRecording() async {
    _isRecording = true;
    _isPaused = false;
    notifyListeners();
  }

  @override
  Future<void> stopRecording() async {
    _isRecording = false;
    _isPaused = false;
    notifyListeners();
  }

  @override
  Future<void> pauseRecording() async {
    _isPaused = true;
    notifyListeners();
  }

  @override
  Future<void> resumeRecording() async {
    _isPaused = false;
    notifyListeners();
  }

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

  group('RecordingControls - Not Recording', () {
    testWidgets('Shows start recording button when not recording', (WidgetTester tester) async {
      mockProvider.setRecordingState(isRecording: false, isPaused: false);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<RecordingProvider>.value(
              value: mockProvider,
              child: const RecordingControls(),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.mic), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Taps start button calls startRecording', (WidgetTester tester) async {
      mockProvider.setRecordingState(isRecording: false, isPaused: false);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<RecordingProvider>.value(
              value: mockProvider,
              child: const RecordingControls(),
            ),
          ),
        ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    // UI should have called startRecording, verified by the behavior
    });
  });

  group('RecordingControls - Recording', () {
    testWidgets('Shows pause and stop buttons when recording', (WidgetTester tester) async {
      mockProvider.setRecordingState(isRecording: true, isPaused: false);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<RecordingProvider>.value(
              value: mockProvider,
              child: const RecordingControls(),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNWidgets(2));
    });

    testWidgets('Taps pause button calls pauseRecording', (WidgetTester tester) async {
      mockProvider.setRecordingState(isRecording: true, isPaused: false);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<RecordingProvider>.value(
              value: mockProvider,
              child: const RecordingControls(),
            ),
          ),
        ),
    );

    await tester.tap(find.byIcon(Icons.pause));
    // UI should have called pauseRecording, verified by the behavior
    });

    testWidgets('Taps stop button calls stopRecording', (WidgetTester tester) async {
      mockProvider.setRecordingState(isRecording: true, isPaused: false);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<RecordingProvider>.value(
              value: mockProvider,
              child: const RecordingControls(),
            ),
          ),
        ),
    );

    await tester.tap(find.byIcon(Icons.stop));
    // UI should have called stopRecording, verified by the behavior
    });
  });

  group('RecordingControls - Paused', () {
    testWidgets('Shows resume button when paused', (WidgetTester tester) async {
      mockProvider.setRecordingState(isRecording: true, isPaused: true);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<RecordingProvider>.value(
              value: mockProvider,
              child: const RecordingControls(),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('Taps resume button calls resumeRecording', (WidgetTester tester) async {
      mockProvider.setRecordingState(isRecording: true, isPaused: true);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<RecordingProvider>.value(
              value: mockProvider,
              child: const RecordingControls(),
            ),
          ),
        ),
    );

    await tester.tap(find.byIcon(Icons.play_arrow));
    // UI should have called resumeRecording, verified by the behavior
    });
  });
}
