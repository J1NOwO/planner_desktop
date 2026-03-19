import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../models/planner_item.dart';
import '../widgets/day_detail_panel.dart';
import '../widgets/month_calendar.dart';

class HomeScreen extends StatelessWidget {
  final AppState appState;

  const HomeScreen({
    super.key,
    required this.appState,
  });

  (List<PlannerItem>, Map<String, DateTime>) _buildScheduleData() {
    final items = <PlannerItem>[];
    final idToDate = <String, DateTime>{};

    for (final entry in appState.schedulesByDate.entries) {
      final parts = entry.key.split('-');
      if (parts.length == 3) {
        final date = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        for (final item in entry.value) {
          items.add(item);
          idToDate[item.id] = date;
        }
      }
    }

    return (items, idToDate);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final (allSchedules, idToDate) = _buildScheduleData();
        DateTime dateForItem(PlannerItem item) =>
            idToDate[item.id] ?? appState.selectedDate;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 1380;

              return Row(
                children: [
                  Expanded(
                    flex: compact ? 11 : 12,
                    child: MonthCalendar<PlannerItem>(
                      displayedMonth: appState.currentMonth,
                      selectedDate: appState.selectedDate,
                      todayDate: appState.todayInSelectedTimeZone,
                      onDateSelected: appState.selectDate,
                      onMonthChanged: appState.changeMonth,
                      onMonthYearPicked: appState.jumpToMonth,
                      items: allSchedules,
                      itemDateBuilder: dateForItem,
                      itemStartDateTimeBuilder: (item) {
                        final date = dateForItem(item);
                        return DateTime(
                          date.year,
                          date.month,
                          date.day,
                          item.startHour,
                          item.startMinute,
                        );
                      },
                      itemPreviewBuilder: (item) => item.title,
                      itemColorBuilder: (item) => Color(item.colorValue),
                      languageCode: appState.language,
                      maxPreviewCount: compact ? 1 : 2,
                    ),
                  ),
                  SizedBox(width: compact ? 12 : 16),
                  Expanded(
                    flex: compact ? 9 : 8,
                    child: DayDetailPanel(appState: appState),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}