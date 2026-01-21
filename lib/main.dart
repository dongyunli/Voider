import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'screens/home_screen.dart';
import 'providers/recording_provider.dart';

void main() {
  runApp(const VoiderApp());
}

class VoiderApp extends StatelessWidget {
  const VoiderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RecordingProvider()),
      ],
      child: MaterialApp(
        title: 'Voider Recorder',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
