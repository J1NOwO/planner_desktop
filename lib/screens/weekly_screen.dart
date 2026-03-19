import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../widgets/weekly_circle_panel.dart';

class WeeklyScreen extends StatelessWidget {
  final AppState appState;

  const WeeklyScreen({
    super.key,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: WeeklyCirclePanel(
            selectedWeekday: appState.selectedWeekday,
            weeklyCircle: appState.weeklyCircle,
            lang: appState.language,
            onAddItem: appState.addWeeklyCircle,
            onRemoveItem: appState.removeWeeklyCircle,
          ),
        );
      },
    );
  }
}
