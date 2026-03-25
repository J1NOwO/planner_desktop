import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'month_picker_dialog.dart';

class MonthCalendar<T> extends StatefulWidget {
  const MonthCalendar({
    super.key,
    required this.displayedMonth,
    required this.selectedDate,
    required this.todayDate,
    required this.onDateSelected,
    required this.onMonthChanged,
    required this.onMonthYearPicked,
    required this.items,
    required this.itemDateBuilder,
    required this.itemPreviewBuilder,
    required this.itemColorBuilder,
    this.itemStartDateTimeBuilder,
    this.maxPreviewCount = 2,
    this.showWeekdayHeader = true,
    this.languageCode = 'en',
  });

  final DateTime displayedMonth;
  final DateTime selectedDate;
  final DateTime todayDate;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onMonthChanged;
  final void Function(int year, int month) onMonthYearPicked;
  final List<T> items;
  final DateTime Function(T item) itemDateBuilder;
  final String Function(T item) itemPreviewBuilder;
  final Color Function(T item) itemColorBuilder;
  final DateTime Function(T item)? itemStartDateTimeBuilder;
  final int maxPreviewCount;
  final bool showWeekdayHeader;
  final String languageCode;

  @override
  State<MonthCalendar<T>> createState() => _MonthCalendarState<T>();
}

class _MonthCalendarState<T> extends State<MonthCalendar<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  static const List<String> _weekdaysEn = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  static const List<String> _weekdaysKo = [
    '일',
    '월',
    '화',
    '수',
    '목',
    '금',
    '토',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstDayOfMonth =
        DateTime(widget.displayedMonth.year, widget.displayedMonth.month, 1);
    final startOffset = firstDayOfMonth.weekday % 7;
    final gridStart = firstDayOfMonth.subtract(Duration(days: startOffset));
    final weekdays =
        widget.languageCode.toLowerCase().startsWith('ko') ? _weekdaysKo : _weekdaysEn;

    return Card(
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact =
                constraints.maxWidth < 900 || constraints.maxHeight < 680;

            final horizontalSpacing = compact ? 4.0 : 8.0;
            final verticalSpacing = compact ? 4.0 : 8.0;
            final headerHeight = compact ? 44.0 : 52.0;
            final weekdayHeight =
                widget.showWeekdayHeader ? (compact ? 20.0 : 28.0) : 0.0;

            final availableWidth = math.max(320.0, constraints.maxWidth);
            final availableHeight = math.max(300.0, constraints.maxHeight);

            final cellWidth = (availableWidth - horizontalSpacing * 6) / 7;
            final targetCellHeight =
                ((availableHeight -
                            headerHeight -
                            weekdayHeight -
                            16 -
                            verticalSpacing * 5) /
                        6)
                    .clamp(compact ? 72.0 : 88.0, 180.0);

            final childAspectRatio =
                math.max(0.2, cellWidth / targetCellHeight);

            return Column(
              children: [
                _MonthHeader(
                  displayedMonth: widget.displayedMonth,
                  languageCode: widget.languageCode,
                  height: headerHeight,
                  onPrev: () {
                    widget.onMonthChanged(
                      DateTime(widget.displayedMonth.year, widget.displayedMonth.month - 1),
                    );
                  },
                  onNext: () {
                    widget.onMonthChanged(
                      DateTime(widget.displayedMonth.year, widget.displayedMonth.month + 1),
                    );
                  },
                  onOpenPicker: () async {
                    final picked = await showDialog<DateTime>(
                      context: context,
                      builder: (_) => MonthPickerDialog(
                        initialYear: widget.displayedMonth.year,
                        initialMonth: widget.displayedMonth.month,
                        lang: widget.languageCode,
                      ),
                    );

                    if (picked != null) {
                      widget.onMonthYearPicked(picked.year, picked.month);
                    }
                  },
                ),
                const SizedBox(height: 8),
                if (widget.showWeekdayHeader)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SizedBox(
                      height: weekdayHeight,
                      child: Row(
                        children: List.generate(7, (index) {
                          final isSunday = index == 0;
                          final isSaturday = index == 6;

                          Color color =
                              theme.colorScheme.onSurface.withOpacity(0.7);
                          if (isSunday) color = Colors.redAccent.withOpacity(0.85);
                          if (isSaturday) {
                            color = Colors.blueAccent.withOpacity(0.85);
                          }

                          return Expanded(
                            child: Center(
                              child: Text(
                                weekdays[index],
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                  fontSize: compact ? 11 : 13,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                Expanded(
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: GridView.builder(
                      controller: _scrollController,
                      physics: const ClampingScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: 42,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        crossAxisSpacing: horizontalSpacing,
                        mainAxisSpacing: verticalSpacing,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemBuilder: (context, index) {
                        final day = gridStart.add(Duration(days: index));
                        final isCurrentMonth = day.month == widget.displayedMonth.month;
                        final isSelected = _sameDay(day, widget.selectedDate);
                        final isToday = _sameDay(day, widget.todayDate);
                        final dayItems = _itemsForDay(day);

                        return _CalendarDayCell<T>(
                          day: day,
                          isCurrentMonth: isCurrentMonth,
                          isSelected: isSelected,
                          isToday: isToday,
                          items: dayItems,
                          itemPreviewBuilder: widget.itemPreviewBuilder,
                          itemColorBuilder: widget.itemColorBuilder,
                          maxPreviewCount: compact ? 0 : widget.maxPreviewCount,
                          compactMode: compact,
                          onTap: () => widget.onDateSelected(day),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<T> _itemsForDay(DateTime day) {
    final filtered = widget.items.where((item) {
      final date = widget.itemDateBuilder(item);
      return _sameDay(date, day);
    }).toList();

    if (widget.itemStartDateTimeBuilder != null) {
      filtered.sort((a, b) {
        return widget.itemStartDateTimeBuilder!(a)
            .compareTo(widget.itemStartDateTimeBuilder!(b));
      });
    }

    return filtered;
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.displayedMonth,
    required this.languageCode,
    required this.height,
    required this.onPrev,
    required this.onNext,
    required this.onOpenPicker,
  });

  final DateTime displayedMonth;
  final String languageCode;
  final double height;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onOpenPicker;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String monthText;
    if (languageCode.toLowerCase().startsWith('ko')) {
      monthText = '${displayedMonth.year}년 ${displayedMonth.month}월';
    } else {
      monthText = '${displayedMonth.year}-${displayedMonth.month.toString().padLeft(2, '0')}';
    }

    return SizedBox(
      height: height,
      child: Row(
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onOpenPicker,
              child: Container(
                height: height,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.surfaceContainerHighest.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  monthText,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _CalendarDayCell<T> extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.isToday,
    required this.items,
    required this.itemPreviewBuilder,
    required this.itemColorBuilder,
    required this.maxPreviewCount,
    required this.compactMode,
    required this.onTap,
  });

  final DateTime day;
  final bool isCurrentMonth;
  final bool isSelected;
  final bool isToday;
  final List<T> items;
  final String Function(T item) itemPreviewBuilder;
  final Color Function(T item) itemColorBuilder;
  final int maxPreviewCount;
  final bool compactMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final previewItems = items.take(maxPreviewCount).toList();
    final remainCount = items.length - previewItems.length;

    Color background = theme.colorScheme.surface;
    Color border = theme.colorScheme.outlineVariant.withOpacity(0.45);
    Color dayNumberColor = isCurrentMonth
        ? theme.colorScheme.onSurface
        : theme.colorScheme.onSurface.withOpacity(0.35);

    if (isToday) {
      background = Colors.redAccent.withOpacity(0.10);
      border = Colors.redAccent.withOpacity(0.45);
    }

    if (isSelected) {
      background = theme.colorScheme.primary.withOpacity(0.14);
      border = theme.colorScheme.primary.withOpacity(0.75);
      dayNumberColor = theme.colorScheme.primary;
    }

    if (isToday && isSelected) {
      background = Color.alphaBlend(
        Colors.redAccent.withOpacity(0.12),
        theme.colorScheme.primary.withOpacity(0.12),
      );
      border = Colors.redAccent.withOpacity(0.75);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(compactMode ? 12 : 18),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(compactMode ? 12 : 18),
            border: Border.all(color: border, width: isToday ? 1.4 : 1.0),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.10),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              compactMode ? 6 : 10,
              compactMode ? 6 : 8,
              compactMode ? 6 : 10,
              compactMode ? 6 : 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${day.day}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: compactMode ? 12 : null,
                        color: dayNumberColor,
                      ),
                    ),
                    const Spacer(),
                    if (isToday)
                      Container(
                        width: compactMode ? 6 : 7,
                        height: compactMode ? 6 : 7,
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.85),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: compactMode
                      ? _CompactIndicator<T>(
                          items: items,
                          itemColorBuilder: itemColorBuilder,
                        )
                      : previewItems.isEmpty
                          ? const SizedBox.shrink()
                          : ClipRect(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final item in previewItems)
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.only(bottom: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: itemColorBuilder(item)
                                            .withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: itemColorBuilder(item)
                                              .withOpacity(0.30),
                                        ),
                                      ),
                                      child: Text(
                                        itemPreviewBuilder(item),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: isCurrentMonth
                                              ? theme.colorScheme.onSurface
                                              : theme.colorScheme.onSurface
                                                  .withOpacity(0.45),
                                        ),
                                      ),
                                    ),
                                  if (remainCount > 0)
                                    Text(
                                      '+$remainCount more',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactIndicator<T> extends StatelessWidget {
  const _CompactIndicator({
    required this.items,
    required this.itemColorBuilder,
  });

  final List<T> items;
  final Color Function(T item) itemColorBuilder;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    if (items.length == 1) {
      return Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: itemColorBuilder(items.first),
            shape: BoxShape.circle,
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.bottomLeft,
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: items.take(3).map((item) {
          return Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: itemColorBuilder(item),
              shape: BoxShape.circle,
            ),
          );
        }).toList(),
      ),
    );
  }
}