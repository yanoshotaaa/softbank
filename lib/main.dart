// pubspec.yaml dependencies needed:
/*
name: poker_analyzer
description: Texas Hold'em Hand Analysis Flutter App

publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  file_picker: ^6.1.1
  csv: ^5.0.2
  json_annotation: ^4.8.1
  provider: ^6.1.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.7
  json_serializable: ^6.7.1
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/
*/

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/poker_analysis_provider.dart';
import 'providers/analysis_history_provider.dart';
import 'providers/mission_provider.dart';
import 'providers/profile_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth/auth_gate.dart';
import 'theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PokerAnalysisProvider()),
        ChangeNotifierProvider(create: (_) => AnalysisHistoryProvider()),
        ChangeNotifierProvider(create: (_) => MissionProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()..loadProfile()),
      ],
      child: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          final theme =
              profileProvider.getPreference<String>('theme', 'system');
          final themeMode = theme == 'dark'
              ? ThemeMode.dark
              : theme == 'light'
                  ? ThemeMode.light
                  : ThemeMode.system;
          return MaterialApp(
            title: 'SoftBank',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}
