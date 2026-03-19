import 'package:flutter/material.dart';
import '../core/app_strings.dart';
import '../models/circle_schedule_item.dart';

class WeeklyCirclePanel extends StatefulWidget {
  final String selectedWeekday;
  final Map<String, List<CircleScheduleItem>> weeklyCircle;
  final String lang;
  final void Function(String day, String title, String time) onAddItem;
  final void Function(String day, String id) onRemoveItem;

  const WeeklyCirclePanel({
    super.key,
    required this.selectedWeekday,
    required this.weeklyCircle,
    required this.lang,
    required this.onAddItem,
    required this.onRemoveItem,
  });

  @override
  State<WeeklyCirclePanel> createState() => _WeeklyCirclePanelState();
}

class _WeeklyCirclePanelState extends State<WeeklyCirclePanel> {
  late String selectedDay;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDay = widget.selectedWeekday;
  }

  @override
  void didUpdateWidget(covariant WeeklyCirclePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedWeekday != widget.selectedWeekday) {
      selectedDay = widget.selectedWeekday;
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = AppStrings.weekDayEntries(widget.lang);
    final items = widget.weeklyCircle[selectedDay] ?? <CircleScheduleItem>[];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppStrings.text(widget.lang, 'weekly_schedule'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 170,
                  child: DropdownButtonFormField<String>(
                    value: selectedDay,
                    items: entries
                        .map(
                          (entry) => DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        selectedDay = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: AppStrings.text(widget.lang, 'title'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: timeController,
                    decoration: InputDecoration(
                      hintText: '18:00',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final time = timeController.text.trim();
                    if (title.isEmpty) return;
                    widget.onAddItem(selectedDay, title, time);
                    titleController.clear();
                    timeController.clear();
                  },
                  child: Text(AppStrings.text(widget.lang, 'add')),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(AppStrings.text(widget.lang, 'no_weekly_items')),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(item.title),
                            subtitle: Text(item.time),
                            trailing: IconButton(
                              onPressed: () =>
                                  widget.onRemoveItem(selectedDay, item.id),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
