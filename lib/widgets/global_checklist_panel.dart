import 'package:flutter/material.dart';
import '../core/app_strings.dart';
import '../models/checklist_item.dart';

class GlobalChecklistPanel extends StatefulWidget {
  final List<ChecklistItem> items;
  final String lang;
  final void Function(String id) onToggle;
  final void Function(String text) onAdd;
  final void Function(String id) onRemove;

  const GlobalChecklistPanel({
    super.key,
    required this.items,
    required this.lang,
    required this.onToggle,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<GlobalChecklistPanel> createState() => _GlobalChecklistPanelState();
}

class _GlobalChecklistPanelState extends State<GlobalChecklistPanel> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppStrings.text(widget.lang, 'global_checklist'),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: AppStrings.text(widget.lang, 'add_recurring_task'),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isEmpty) return;
                    widget.onAdd(text);
                    controller.clear();
                  },
                  child: Text(AppStrings.text(widget.lang, 'add')),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: widget.items.isEmpty
                  ? Center(
                      child: Text(AppStrings.text(widget.lang, 'no_recurring_tasks')),
                    )
                  : ListView.builder(
                      itemCount: widget.items.length,
                      itemBuilder: (context, index) {
                        final item = widget.items[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: CheckboxListTile(
                            value: item.done,
                            onChanged: (_) => widget.onToggle(item.id),
                            title: Text(
                              item.text,
                              style: TextStyle(
                                decoration: item.done
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            secondary: IconButton(
                              onPressed: () => widget.onRemove(item.id),
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
