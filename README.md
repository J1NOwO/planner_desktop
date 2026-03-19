# Planner Desktop

A desktop planner app built with Flutter.
Manage your monthly calendar, circular timetable, and checklists all in one place.

---

## Features

### Home (Monthly Calendar)
- View all schedules at a glance on a monthly calendar
- Click a date to see its details in the right panel
- Add schedules with start/end time and custom color
- Write a memo for each date

### Checklist
- **Global checklist**: Manage daily recurring routines (e.g. drink water, exercise)
- **Date-specific checklist**: Add one-off tasks for a particular date
- Global item completion is tracked independently per date

### Weekly Circular Timetable
- Visualize weekly routines with a circular timetable per day
- Add or remove items for each weekday

### Settings
- **Language**: Korean / English
- **Theme**: Light / Dark / System
- **Timezone**: Select from major cities — Seoul, Tokyo, New York, London, and more

---

## Tech Stack

| | |
|---|---|
| Framework | Flutter 3.x (Dart) |
| UI | Material 3 |
| State Management | `ChangeNotifier` |
| Packages | `timezone` |
| Platforms | Windows · macOS · Linux · Android · iOS · Web |

---

## Getting Started

### Requirements
- Flutter SDK `^3.5.3`

### Install & Run

```bash
# Install dependencies
flutter pub get

# Run on desktop (Windows)
flutter run -d windows

# Other platforms
flutter run -d macos
flutter run -d linux
```

### Build

```bash
# Windows release build
flutter build windows --release
```

---

## Project Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── app_state.dart              # Global state management
│   ├── app_theme.dart              # Light / dark theme definitions
│   └── app_strings.dart            # Localized strings
├── models/
│   ├── planner_item.dart           # Schedule data model
│   ├── checklist_item.dart         # Checklist item model
│   └── circle_schedule_item.dart   # Circular timetable item model
├── screens/
│   ├── main_shell.dart             # Navigation shell
│   ├── home_screen.dart            # Monthly calendar screen
│   ├── checklist_screen.dart       # Checklist screen
│   ├── weekly_screen.dart          # Weekly circular timetable screen
│   └── settings_screen.dart        # Settings screen
├── widgets/
│   ├── month_calendar.dart                # Monthly calendar widget
│   ├── day_detail_panel.dart              # Day detail panel
│   ├── circular_day_timetable.dart        # Circular timetable widget
│   ├── weekly_circle_panel.dart           # Weekly circular panel
│   ├── global_checklist_panel.dart        # Global checklist panel
│   ├── planner_clock_time_picker.dart     # Clock-style time picker
│   ├── custom_color_picker_dialog.dart    # Color picker dialog
│   └── month_picker_dialog.dart           # Month picker dialog
└── utils/
    └── date_utils.dart             # Date utility functions
```
