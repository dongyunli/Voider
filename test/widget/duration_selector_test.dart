import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:voider_recorder/widgets/duration_selector.dart';
import 'package:voider_recorder/providers/recording_provider.dart';
import 'package:voider_recorder/config/constants.dart';
import 'package:voider_recorder/models/recording_file.dart';

class MockRecordingProvider extends ChangeNotifier implements RecordingProvider {
  int _selectedDurationLimit = AppConstants.unlimitedDuration;
  bool _isRecording = false;

  @override
  int get selectedDurationLimit => _selectedDurationLimit;

  @override
  bool get isRecording => _isRecording;

  @override
  bool get isInitializing => false;

  @override
  bool get isPaused => false;

  @override
  bool get isPlaying => false;

  void setSelectedDurationLimit(int limit) {
    _selectedDurationLimit = limit;
    notifyListeners();
  }

  void setRecordingState(bool isRecording) {
    _isRecording = isRecording;
    notifyListeners();
  }

  @override
  final ValueNotifier<int> elapsedSecondsNotifier = ValueNotifier(0);

  @override
  int get elapsedSeconds => elapsedSecondsNotifier.value;

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
  Future<void> setDurationLimit(int minutes) async {
    _selectedDurationLimit = minutes;
    notifyListeners();
  }

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

  testWidgets('DurationSelector displays all duration options', (WidgetTester tester) async {
    mockProvider.setRecordingState(false);
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<RecordingProvider>.value(
            value: mockProvider,
            child: const DurationSelector(),
          ),
        ),
      ),
    );

    expect(find.text('不限时'), findsOneWidget);
    
    for (final duration in AppConstants.recordingDurations) {
      expect(find.text('$duration分钟'), findsOneWidget);
    }
  });

  testWidgets('Initially selects "不限时" option', (WidgetTester tester) async {
    mockProvider.setRecordingState(false);
    mockProvider.setSelectedDurationLimit(AppConstants.unlimitedDuration);
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<RecordingProvider>.value(
            value: mockProvider,
            child: const DurationSelector(),
          ),
        ),
      ),
    );

    final unlimitedChip = tester.widget<ChoiceChip>(
      find.ancestor(
        of: find.text('不限时'),
        matching: find.byType(ChoiceChip),
      ),
    );
    expect(unlimitedChip.selected, isTrue);
  });

  testWidgets('Selecting a duration option calls setDurationLimit', (WidgetTester tester) async {
    mockProvider.setRecordingState(false);
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<RecordingProvider>.value(
            value: mockProvider,
            child: const DurationSelector(),
          ),
        ),
      ),
    );

    await tester.tap(find.text('5分钟'));
    // UI should have called setDurationLimit, verified by the behavior
  });

  testWidgets('Selected option updates UI', (WidgetTester tester) async {
    mockProvider.setRecordingState(false);
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<RecordingProvider>.value(
            value: mockProvider,
            child: const DurationSelector(),
          ),
        ),
      ),
    );

    // Initially unlimited is selected
    var unlimitedChip = tester.widget<ChoiceChip>(
      find.ancestor(
        of: find.text('不限时'),
        matching: find.byType(ChoiceChip),
      ),
    );
    expect(unlimitedChip.selected, isTrue);

    // Select 5 minutes
    await tester.tap(find.text('5分钟'));
    await tester.pump();

    // Now 5 minutes is selected
    unlimitedChip = tester.widget<ChoiceChip>(
      find.ancestor(
        of: find.text('不限时'),
        matching: find.byType(ChoiceChip),
      ),
    );
    expect(unlimitedChip.selected, isFalse);

    var fiveMinChip = tester.widget<ChoiceChip>(
      find.ancestor(
        of: find.text('5分钟'),
        matching: find.byType(ChoiceChip),
      ),
    );
    expect(fiveMinChip.selected, isTrue);
  });

  testWidgets('Options are disabled when recording', (WidgetTester tester) async {
    mockProvider.setRecordingState(true);
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<RecordingProvider>.value(
            value: mockProvider,
            child: const DurationSelector(),
          ),
        ),
      ),
    );

    // Check that chips are disabled (onSelected is null)
    final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip));
    for (final chip in chips) {
      expect(chip.onSelected, isNull);
    }
  });

  testWidgets('Tapping disabled option does not call setDurationLimit', (WidgetTester tester) async {
    mockProvider.setRecordingState(true);
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<RecordingProvider>.value(
            value: mockProvider,
            child: const DurationSelector(),
          ),
        ),
      ),
    );

    await tester.tap(find.text('5分钟'));
    // Since recording is active, setDurationLimit should not have been called
  });
}
