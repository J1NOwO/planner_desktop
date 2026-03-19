import 'package:flutter/material.dart';
import '../models/planner_item.dart';
import '../models/checklist_item.dart';
import '../models/circle_schedule_item.dart';
import '../utils/date_utils.dart';

class AppState extends ChangeNotifier {
  static int _idCounter = 0;
  static String _generateId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${_idCounter++}';

  int _selectedIndex = 0;
  String _language = 'ko';
  ThemeMode _themeMode = ThemeMode.dark;

  DateTime _selectedDate = DateTime.now();
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);

  String _selectedTimeZone = 'Local';

  final Map<String, List<PlannerItem>> schedulesByDate = {};
  final Map<String, List<ChecklistItem>> checklistsByDate = {};
  final Map<String, Set<String>> _globalDoneByDate = {};
  final Map<String, String> memosByDate = {};

  final List<ChecklistItem> globalChecklist = [
    ChecklistItem(id: 'g1', text: 'Drink water'),
    ChecklistItem(id: 'g2', text: 'Study / coding'),
    ChecklistItem(id: 'g3', text: 'Exercise'),
  ];

  final Map<String, List<CircleScheduleItem>> weeklyCircle = {
    'Sun': [],
    'Mon': [],
    'Tue': [],
    'Wed': [],
    'Thu': [],
    'Fri': [],
    'Sat': [],
  };

  static const List<String> availableTimeZones = [
    'Local',
    'UTC',
    'America/Chicago',
    'America/New_York',
    'America/Denver',
    'America/Los_Angeles',
    'Asia/Seoul',
    'Asia/Tokyo',
    'Europe/London',
    'Europe/Paris',
  ];

  static const Map<String, int> _utcOffsets = {
    'UTC': 0,
    'America/Chicago': -6,
    'America/New_York': -5,
    'America/Denver': -7,
    'America/Los_Angeles': -8,
    'Asia/Seoul': 9,
    'Asia/Tokyo': 9,
    'Europe/London': 0,
    'Europe/Paris': 1,
  };

  static const Map<String, Map<String, String>> _timeZoneLabels = {
    'Local': {
      'ko': '기기 로컬 시간',
      'en': 'Local Device Time',
    },
    'UTC': {
      'ko': 'UTC',
      'en': 'UTC',
    },
    'America/Chicago': {
      'ko': '미국 중부 (Chicago)',
      'en': 'America/Chicago',
    },
    'America/New_York': {
      'ko': '미국 동부 (New York)',
      'en': 'America/New_York',
    },
    'America/Denver': {
      'ko': '미국 산악 (Denver)',
      'en': 'America/Denver',
    },
    'America/Los_Angeles': {
      'ko': '미국 서부 (Los Angeles)',
      'en': 'America/Los_Angeles',
    },
    'Asia/Seoul': {
      'ko': '한국 (Seoul)',
      'en': 'Asia/Seoul',
    },
    'Asia/Tokyo': {
      'ko': '일본 (Tokyo)',
      'en': 'Asia/Tokyo',
    },
    'Europe/London': {
      'ko': '영국 (London)',
      'en': 'Europe/London',
    },
    'Europe/Paris': {
      'ko': '프랑스 (Paris)',
      'en': 'Europe/Paris',
    },
  };

  int get selectedIndex => _selectedIndex;
  String get language => _language;
  ThemeMode get themeMode => _themeMode;
  DateTime get selectedDate => _selectedDate;
  DateTime get currentMonth => _currentMonth;
  String get selectedTimeZone => _selectedTimeZone;

  DateTime get zonedNow {
    if (_selectedTimeZone == 'Local') {
      return DateTime.now();
    }

    final offset = _utcOffsets[_selectedTimeZone] ?? 0;
    return DateTime.now().toUtc().add(Duration(hours: offset));
  }

  DateTime get todayInSelectedTimeZone {
    final now = zonedNow;
    return DateTime(now.year, now.month, now.day);
  }

  String get currentTimeZoneLabel =>
      _timeZoneLabels[_selectedTimeZone]?[_language] ?? _selectedTimeZone;

  String get zonedNowText {
    final now = zonedNow;
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final ss = now.second.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm:$ss';
  }

  List<PlannerItem> get selectedSchedules {
    final list = schedulesByDate[dateKey(_selectedDate)] ?? <PlannerItem>[];
    final copied = List<PlannerItem>.from(list);
    copied.sort((a, b) => a.startTotalMinutes.compareTo(b.startTotalMinutes));
    return copied;
  }

  List<ChecklistItem> get selectedChecklist {
    final key = dateKey(_selectedDate);
    final doneSet = _globalDoneByDate[key] ?? <String>{};

    final globalItems = globalChecklist
        .map((item) => ChecklistItem(
              id: item.id,
              text: item.text,
              done: doneSet.contains(item.id),
              isGlobal: true,
            ))
        .toList();

    final dateItems =
        List<ChecklistItem>.from(checklistsByDate[key] ?? <ChecklistItem>[]);

    return [...globalItems, ...dateItems];
  }

  String get selectedMemo => memosByDate[dateKey(_selectedDate)] ?? '';

  String get selectedWeekday => weekdayCode(_selectedDate);

  bool isTodayInSelectedTimeZone(DateTime date) {
    return date.year == todayInSelectedTimeZone.year &&
        date.month == todayInSelectedTimeZone.month &&
        date.day == todayInSelectedTimeZone.day;
  }

  String timeZoneLabel(String zone, String lang) {
    return _timeZoneLabels[zone]?[lang] ?? zone;
  }

  void changeTab(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void changeLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  void changeThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void changeTimeZone(String zone) {
    _selectedTimeZone = zone;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    _currentMonth = DateTime(date.year, date.month);
    notifyListeners();
  }

  void changeMonth(DateTime month) {
    _currentMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  void jumpToMonth(int year, int month) {
    _currentMonth = DateTime(year, month);

    final lastDay = DateTime(year, month + 1, 0).day;
    final safeDay = _selectedDate.day > lastDay ? lastDay : _selectedDate.day;
    _selectedDate = DateTime(year, month, safeDay);

    notifyListeners();
  }

  void addSchedule({
    required String title,
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
    required int colorValue,
  }) {
    final key = dateKey(_selectedDate);
    schedulesByDate.putIfAbsent(key, () => <PlannerItem>[]);

    schedulesByDate[key]!.add(
      PlannerItem(
        id: _generateId(),
        title: title,
        startHour: startHour,
        startMinute: startMinute,
        endHour: endHour,
        endMinute: endMinute,
        colorValue: colorValue,
      ),
    );

    schedulesByDate[key]!.sort(
      (a, b) => a.startTotalMinutes.compareTo(b.startTotalMinutes),
    );

    notifyListeners();
  }

  void removeSchedule(String id) {
    final key = dateKey(_selectedDate);
    schedulesByDate[key]?.removeWhere((PlannerItem item) => item.id == id);
    notifyListeners();
  }

  void updateMemo(String value) {
    memosByDate[dateKey(_selectedDate)] = value;
    notifyListeners();
  }

  void addDateChecklist(String text) {
    final key = dateKey(_selectedDate);
    checklistsByDate.putIfAbsent(key, () => <ChecklistItem>[]);

    checklistsByDate[key]!.add(
      ChecklistItem(
        id: _generateId(),
        text: text,
      ),
    );

    notifyListeners();
  }

  void toggleDateChecklist(String id) {
    final key = dateKey(_selectedDate);
    final list = checklistsByDate[key];
    if (list == null) return;

    final index = list.indexWhere((item) => item.id == id);
    if (index != -1) {
      list[index] = list[index].copyWith(done: !list[index].done);
    }
    notifyListeners();
  }

  void removeDateChecklist(String id) {
    final key = dateKey(_selectedDate);
    checklistsByDate[key]?.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void toggleGlobalChecklist(String id) {
    final index = globalChecklist.indexWhere((item) => item.id == id);
    if (index != -1) {
      globalChecklist[index] =
          globalChecklist[index].copyWith(done: !globalChecklist[index].done);
    }
    notifyListeners();
  }

  void toggleGlobalChecklistForDate(String id) {
    final key = dateKey(_selectedDate);
    _globalDoneByDate.putIfAbsent(key, () => <String>{});
    if (_globalDoneByDate[key]!.contains(id)) {
      _globalDoneByDate[key]!.remove(id);
    } else {
      _globalDoneByDate[key]!.add(id);
    }
    notifyListeners();
  }

  void addGlobalChecklist(String text) {
    globalChecklist.add(
      ChecklistItem(
        id: _generateId(),
        text: text,
      ),
    );
    notifyListeners();
  }

  void removeGlobalChecklist(String id) {
    globalChecklist.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void addWeeklyCircle(String day, String title, String time) {
    weeklyCircle.putIfAbsent(day, () => <CircleScheduleItem>[]);

    weeklyCircle[day]!.add(
      CircleScheduleItem(
        id: _generateId(),
        title: title,
        time: time,
      ),
    );
    notifyListeners();
  }

  void removeWeeklyCircle(String day, String id) {
    weeklyCircle[day]?.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}