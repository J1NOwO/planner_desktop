# Planner Desktop

> A Flutter desktop app for managing your monthly calendar, circular timetable, and checklists — all in one place.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat&logo=dart&logoColor=white)
![Material 3](https://img.shields.io/badge/Material-3-757575?style=flat&logo=google&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=flat)
![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey?style=flat)

---

## Project Overview

Planner Desktop is a cross-platform productivity app built with Flutter. It combines a monthly calendar, a clock-style circular timetable, and a layered checklist system into a single, unified interface — designed for users who want a clean visual overview of their schedule.

---

## Key Features

### Monthly Calendar
- View all schedules at a glance on a monthly grid
- Click any date to see details in a side panel
- Add events with start/end time and custom color
- Write per-date memos

### Checklist
- **Global checklist** — Manage daily recurring routines (e.g. exercise, hydration)
- **Date-specific checklist** — Add one-off tasks for a specific date
- Global item completion is tracked independently per date

### Weekly Circular Timetable
- Visualize weekly routines with a circular (clock-style) timetable per weekday
- Add or remove time blocks for each day

### Settings
- Language: Korean / English
- Theme: Light / Dark / System default
- Timezone: Select from major cities (Seoul, Tokyo, New York, London, and more)

---

## Tech Stack

| Category          | Technology                          |
|-------------------|-------------------------------------|
| Framework         | Flutter 3.x (Dart)                  |
| UI Design System  | Material 3                          |
| State Management  | `ChangeNotifier`                    |
| Key Packages      | `timezone ^0.11.0`                  |
| Platforms         | Windows · macOS · Linux · Android · iOS · Web |

---

## Project Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── app_state.dart              # Global state management
│   ├── app_theme.dart              # Light / dark theme definitions
│   └── app_strings.dart            # Localized strings (KO / EN)
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

---

## Installation

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) `^3.5.3`
- Dart `^3.x` (bundled with Flutter)

### Setup

```bash
# Clone the repository
git clone https://github.com/J1NOwO/planner_desktop.git
cd planner_desktop

# Install dependencies
flutter pub get
```

---

## Usage

```bash
# Run on Windows
flutter run -d windows

# Run on macOS
flutter run -d macos

# Run on Linux
flutter run -d linux

# Run on web (for quick preview)
flutter run -d chrome
```

### Build for Release

```bash
# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

---

## Environment Variables

This project does not require environment variables for basic usage.

If you extend the app with external APIs (e.g. Google Calendar sync), create a `.env` file at the project root:

```env
# .env.example

# Example: Google Calendar API (not implemented by default)
GOOGLE_CLIENT_ID=your_client_id_here
GOOGLE_CLIENT_SECRET=your_client_secret_here
```

> Do not commit your `.env` file. Add it to `.gitignore`.

---

## Contributing

Contributions are welcome!

```bash
# 1. Fork the repository
# 2. Create your feature branch
git checkout -b feature/your-feature-name

# 3. Commit your changes
git commit -m "feat: add your feature"

# 4. Push to the branch
git push origin feature/your-feature-name

# 5. Open a Pull Request
```

Please keep PRs focused and include a brief description of what was changed and why.

---

## License

This project is licensed under the [MIT License](LICENSE).

Copyright (c) 2026 Jinwoo Yoon
