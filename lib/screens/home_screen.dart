import 'package:flutter/material.dart';
import '../widgets/timer_display.dart';
import '../widgets/duration_selector.dart';
import '../widgets/recording_controls.dart';
import 'recording_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Voider 录音机')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return _buildTabletLayout();
          } else {
            return _buildPhoneLayout();
          }
        },
      ),
    );
  }

  Widget _buildTabletLayout() {
    return const Row(
      children: [
        // Left: List
        Expanded(
          flex: 4,
          child: RecordingListScreen(),
        ),
        VerticalDivider(width: 1),
        // Right: Controls
        Expanded(
          flex: 6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TimerDisplay(),
                SizedBox(height: 40),
                DurationSelector(),
                SizedBox(height: 60),
                RecordingControls(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneLayout() {
    return const Column(
      children: [
        // Top: Controls
        Expanded(
          flex: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              TimerDisplay(),
              SizedBox(height: 20),
              DurationSelector(),
              SizedBox(height: 30),
              RecordingControls(),
              Spacer(),
            ],
          ),
        ),
        Divider(height: 1),
        // Bottom: List
        Expanded(
          flex: 4,
          child: RecordingListScreen(),
        ),
      ],
    );
  }
}
