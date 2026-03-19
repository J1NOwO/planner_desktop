import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../core/app_strings.dart';
import 'home_screen.dart';
import 'weekly_screen.dart';
import 'checklist_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  final AppState appState;

  const MainShell({
    super.key,
    required this.appState,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(appState: widget.appState),
      WeeklyScreen(appState: widget.appState),
      ChecklistScreen(appState: widget.appState),
      SettingsScreen(appState: widget.appState),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final lang = widget.appState.language;

        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.text(lang, 'app_title')),
          ),
          body: IndexedStack(
            index: widget.appState.selectedIndex,
            children: _screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: widget.appState.selectedIndex,
            onDestinationSelected: widget.appState.changeTab,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: AppStrings.text(lang, 'home'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.view_week_outlined),
                selectedIcon: const Icon(Icons.view_week),
                label: AppStrings.text(lang, 'weekly'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.check_box_outlined),
                selectedIcon: const Icon(Icons.check_box),
                label: AppStrings.text(lang, 'checklist'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings),
                label: AppStrings.text(lang, 'settings'),
              ),
            ],
          ),
        );
      },
    );
  }
}
