import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../widgets/global_checklist_panel.dart';

class ChecklistScreen extends StatelessWidget {
  final AppState appState;

  const ChecklistScreen({
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
          child: GlobalChecklistPanel(
            items: appState.globalChecklist,
            lang: appState.language,
            onToggle: appState.toggleGlobalChecklist,
            onAdd: appState.addGlobalChecklist,
            onRemove: appState.removeGlobalChecklist,
          ),
        );
      },
    );
  }
}
