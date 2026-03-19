import 'package:flutter/material.dart';
import 'core/app_state.dart';
import 'core/app_theme.dart';
import 'screens/main_shell.dart';

class PlannerDesktopApp extends StatefulWidget {
  const PlannerDesktopApp({super.key});

  @override
  State<PlannerDesktopApp> createState() => _PlannerDesktopAppState();
}

class _PlannerDesktopAppState extends State<PlannerDesktopApp> {
  final AppState appState = AppState();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'Planner Desktop',
          debugShowCheckedModeBanner: false,
          themeMode: appState.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: MainShell(appState: appState),
        );
      },
    );
  }
}
