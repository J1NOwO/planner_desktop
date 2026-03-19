import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../core/app_strings.dart';
import '../models/checklist_item.dart';
import '../models/planner_item.dart';
import 'circular_day_timetable.dart';
import 'custom_color_picker_dialog.dart';
import 'planner_clock_time_picker.dart';

class DayDetailPanel extends StatefulWidget {
  final AppState appState;

  const DayDetailPanel({
    super.key,
    required this.appState,
  });

  @override
  State<DayDetailPanel> createState() => _DayDetailPanelState();
}

class _DayDetailPanelState extends State<DayDetailPanel>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController checklistController = TextEditingController();
  late final TextEditingController memoController;

  PlannerClockTime? startTime;
  PlannerClockTime? endTime;
  int selectedColorValue = _colorOptions.first.value;
  DateTime? _previousSelectedDate;

  static const List<Color> _colorOptions = [
    Color(0xFF3B82F6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
    Color(0xFFEAB308),
    Color(0xFF6366F1),
    Color(0xFF22C55E),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    memoController = TextEditingController(
      text: widget.appState.selectedMemo,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    titleController.dispose();
    checklistController.dispose();
    memoController.dispose();
    super.dispose();
  }

  String _formatClockTime(PlannerClockTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final ampm = t.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  Future<void> _pickStartTime() async {
    final result = await showPlannerClockTimePicker(
      context: context,
      language: widget.appState.language,
      initialTime: startTime ?? const PlannerClockTime(hour: 9, minute: 0),
    );

    if (result != null) {
      setState(() {
        startTime = result;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final result = await showPlannerClockTimePicker(
      context: context,
      language: widget.appState.language,
      initialTime: endTime ?? const PlannerClockTime(hour: 10, minute: 0),
    );

    if (result != null) {
      setState(() {
        endTime = result;
      });
    }
  }

  Future<void> _pickCustomColor() async {
    final picked = await showCustomColorPickerDialog(
      context: context,
      initialColor: Color(selectedColorValue),
    );

    if (picked != null) {
      setState(() {
        selectedColorValue = picked.value;
      });
    }
  }

  void _addSchedule() {
    final lang = widget.appState.language;
    final title = titleController.text.trim();

    if (title.isEmpty || startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.text(lang, 'time_required'))),
      );
      return;
    }

    final startMinutes = startTime!.hour * 60 + startTime!.minute;
    final endMinutes = endTime!.hour * 60 + endTime!.minute;

    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.text(lang, 'invalid_time_range'))),
      );
      return;
    }

    widget.appState.addSchedule(
      title: title,
      startHour: startTime!.hour,
      startMinute: startTime!.minute,
      endHour: endTime!.hour,
      endMinute: endTime!.minute,
      colorValue: selectedColorValue,
    );

    titleController.clear();
    setState(() {
      startTime = null;
      endTime = null;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.appState.language;

    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final schedules = widget.appState.selectedSchedules;
        final checklist = widget.appState.selectedChecklist;
        final selectedDate = widget.appState.selectedDate;

        if (_previousSelectedDate != selectedDate) {
          _previousSelectedDate = selectedDate;
          final memo = widget.appState.selectedMemo;
          memoController.value = TextEditingValue(
            text: memo,
            selection: TextSelection.collapsed(offset: memo.length),
          );
        }

        return Card(
          clipBehavior: Clip.hardEdge,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _formatDate(widget.appState.selectedDate),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(text: AppStrings.text(lang, 'schedule')),
                    Tab(text: AppStrings.text(lang, 'checklist')),
                    Tab(text: AppStrings.text(lang, 'memo')),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildScheduleTab(lang, schedules),
                      _buildChecklistTab(lang, checklist),
                      _buildMemoTab(lang),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScheduleTab(String lang, List<PlannerItem> schedules) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620 || constraints.maxHeight < 700;
        final circleSize = compact ? 190.0 : 220.0;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: compact
                    ? Column(
                        children: [
                          CircularDayTimetable<PlannerItem>(
                            items: schedules,
                            size: circleSize,
                            startDateTimeBuilder: (item) => DateTime(
                              widget.appState.selectedDate.year,
                              widget.appState.selectedDate.month,
                              widget.appState.selectedDate.day,
                              item.startHour,
                              item.startMinute,
                            ),
                            endDateTimeBuilder: (item) => DateTime(
                              widget.appState.selectedDate.year,
                              widget.appState.selectedDate.month,
                              widget.appState.selectedDate.day,
                              item.endHour,
                              item.endMinute,
                            ),
                            colorBuilder: (item) => Color(item.colorValue),
                          ),
                          const SizedBox(height: 16),
                          AnalogLiveClock(
                            now: widget.appState.zonedNow,
                            timeZoneLabel:
                                widget.appState.currentTimeZoneLabel,
                            size: circleSize,
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              CircularDayTimetable<PlannerItem>(
                                items: schedules,
                                size: circleSize,
                                startDateTimeBuilder: (item) => DateTime(
                                  widget.appState.selectedDate.year,
                                  widget.appState.selectedDate.month,
                                  widget.appState.selectedDate.day,
                                  item.startHour,
                                  item.startMinute,
                                ),
                                endDateTimeBuilder: (item) => DateTime(
                                  widget.appState.selectedDate.year,
                                  widget.appState.selectedDate.month,
                                  widget.appState.selectedDate.day,
                                  item.endHour,
                                  item.endMinute,
                                ),
                                colorBuilder: (item) => Color(item.colorValue),
                              ),
                              const SizedBox(height: 8),
                              const Text('Timetable'),
                            ],
                          ),
                          Column(
                            children: [
                              AnalogLiveClock(
                                now: widget.appState.zonedNow,
                                timeZoneLabel:
                                    widget.appState.currentTimeZoneLabel,
                                size: circleSize,
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SizedBox(
                      width: compact ? double.infinity : 220,
                      child: TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: AppStrings.text(lang, 'title'),
                        ),
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: _pickStartTime,
                      child: Text(
                        startTime == null
                            ? AppStrings.text(lang, 'start_time')
                            : startTime!.format(context),
                      ),
                    ),
                    FilledButton.tonal(
                      onPressed: _pickEndTime,
                      child: Text(
                        endTime == null
                            ? AppStrings.text(lang, 'end_time')
                            : endTime!.format(context),
                      ),
                    ),
                    FilledButton(
                      onPressed: _addSchedule,
                      child: Text(AppStrings.text(lang, 'add')),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppStrings.text(lang, 'pick_color'),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ..._colorOptions.map((color) {
                      final selected = selectedColorValue == color.value;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColorValue = color.value;
                          });
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  selected ? Colors.white : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    }),
                    OutlinedButton(
                      onPressed: _pickCustomColor,
                      child: const Text('Custom'),
                    ),
                  ],
                ),
              ),
            ),
            if (schedules.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(AppStrings.text(lang, 'no_schedule_items')),
                ),
              )
            else
              SliverList.builder(
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final item = schedules[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      tileColor: Color(item.colorValue).withOpacity(0.10),
                      leading: CircleAvatar(
                        backgroundColor: Color(item.colorValue),
                        radius: 10,
                      ),
                      title: Text(item.title),
                      subtitle: Text(item.rangeText),
                      trailing: IconButton(
                        onPressed: () => widget.appState.removeSchedule(item.id),
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildChecklistTab(String lang, List<ChecklistItem> checklist) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: checklistController,
                    decoration: InputDecoration(
                      hintText: AppStrings.text(lang, 'checklist_item'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    final text = checklistController.text.trim();
                    if (text.isEmpty) return;
                    widget.appState.addDateChecklist(text);
                    checklistController.clear();
                  },
                  child: Text(AppStrings.text(lang, 'add')),
                ),
              ],
            ),
          ),
        ),
        if (checklist.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(AppStrings.text(lang, 'no_checklist_items')),
            ),
          )
        else
          SliverList.builder(
            itemCount: checklist.length,
            itemBuilder: (context, index) {
              final item = checklist[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: CheckboxListTile(
                  value: item.done,
                  onChanged: (_) => item.isGlobal
                      ? widget.appState.toggleGlobalChecklistForDate(item.id)
                      : widget.appState.toggleDateChecklist(item.id),
                  title: Text(
                    item.text,
                    style: TextStyle(
                      decoration: item.done
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  secondary: item.isGlobal
                      ? const Icon(Icons.repeat, size: 20, color: Colors.grey)
                      : IconButton(
                          onPressed: () =>
                              widget.appState.removeDateChecklist(item.id),
                          icon: const Icon(Icons.delete_outline),
                        ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildMemoTab(String lang) {
    return TextField(
      controller: memoController,
      expands: true,
      minLines: null,
      maxLines: null,
      onChanged: widget.appState.updateMemo,
      decoration: InputDecoration(
        hintText: AppStrings.text(lang, 'memo_hint'),
      ),
    );
  }
}