import 'package:flutter/material.dart';
import '../core/app_strings.dart';

class MonthPickerDialog extends StatefulWidget {
  final int initialYear;
  final int initialMonth;
  final String lang;

  const MonthPickerDialog({
    super.key,
    required this.initialYear,
    required this.initialMonth,
    required this.lang,
  });

  @override
  State<MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  late int selectedYear;
  late int selectedMonth;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialYear;
    selectedMonth = widget.initialMonth;
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;

    return AlertDialog(
      title: Text(AppStrings.text(lang, 'month_picker')),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              initialValue: selectedYear,
              items: List.generate(
                21,
                (index) {
                  final year = DateTime.now().year - 10 + index;
                  return DropdownMenuItem(
                    value: year,
                    child: Text(year.toString()),
                  );
                },
              ),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  selectedYear = value;
                });
              },
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              itemCount: 12,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.8,
              ),
              itemBuilder: (context, index) {
                final month = index + 1;
                final selected = selectedMonth == month;

                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedMonth = month;
                    });
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(month.toString()),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppStrings.text(lang, 'cancel')),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(
              context,
              DateTime(selectedYear, selectedMonth),
            );
          },
          child: Text(AppStrings.text(lang, 'apply')),
        ),
      ],
    );
  }
}
