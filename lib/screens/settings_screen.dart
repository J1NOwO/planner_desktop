import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../core/app_strings.dart';

class SettingsScreen extends StatelessWidget {
  final AppState appState;

  const SettingsScreen({
    super.key,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final lang = appState.language;
        final theme = Theme.of(context);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  Text(
                    AppStrings.text(lang, 'settings'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.text(lang, 'language'),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: appState.language,
                    items: [
                      DropdownMenuItem(
                        value: 'ko',
                        child: Text(AppStrings.text(lang, 'korean')),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Text(AppStrings.text(lang, 'english')),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      appState.changeLanguage(value);
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.text(lang, 'theme'),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<ThemeMode>(
                    value: appState.themeMode,
                    items: [
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text(AppStrings.text(lang, 'light')),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text(AppStrings.text(lang, 'dark')),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text(AppStrings.text(lang, 'system')),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      appState.changeThemeMode(value);
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppStrings.text(lang, 'timezone'),
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.text(lang, 'timezone_hint'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: appState.selectedTimeZone,
                    items: AppState.availableTimeZones.map((zone) {
                      return DropdownMenuItem(
                        value: zone,
                        child: Text(appState.timeZoneLabel(zone, lang)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      appState.changeTimeZone(value);
                    },
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.surfaceContainerHighest.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.text(lang, 'timezone'),
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          appState.currentTimeZoneLabel,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.text(lang, 'current_time'),
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          appState.zonedNowText,
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}