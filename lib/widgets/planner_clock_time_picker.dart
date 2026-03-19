import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_strings.dart';

enum PlannerClockUnit {
  hour,
  minute,
}

class PlannerClockTime {
  const PlannerClockTime({
    required this.hour,
    required this.minute,
  });

  final int hour;
  final int minute;

  PlannerClockTime copyWith({
    int? hour,
    int? minute,
  }) {
    return PlannerClockTime(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  String format(BuildContext context) {
    return TimeOfDay(hour: hour, minute: minute).format(context);
  }
}

Future<PlannerClockTime?> showPlannerClockTimePicker({
  required BuildContext context,
  required String language,
  PlannerClockTime? initialTime,
}) {
  return showDialog<PlannerClockTime>(
    context: context,
    barrierDismissible: false,
    builder: (_) => PlannerClockTimePickerDialog(
      language: language,
      initialTime: initialTime ??
          PlannerClockTime(
            hour: TimeOfDay.now().hour,
            minute: TimeOfDay.now().minute,
          ),
    ),
  );
}

class PlannerClockTimePickerDialog extends StatefulWidget {
  const PlannerClockTimePickerDialog({
    super.key,
    required this.language,
    required this.initialTime,
  });

  final String language;
  final PlannerClockTime initialTime;

  @override
  State<PlannerClockTimePickerDialog> createState() =>
      _PlannerClockTimePickerDialogState();
}

class _PlannerClockTimePickerDialogState
    extends State<PlannerClockTimePickerDialog> {
  late PlannerClockTime _time;
  PlannerClockUnit _activeUnit = PlannerClockUnit.hour;
  bool _isAm = true;

  @override
  void initState() {
    super.initState();
    _time = widget.initialTime;
    _isAm = _time.hour < 12;
  }

  int get _displayHour {
    final h = _time.hour % 12;
    return h == 0 ? 12 : h;
  }

  void _setDisplayHour(int displayHour) {
    int newHour = displayHour % 12;

    if (_isAm && displayHour == 12) {
      newHour = 0;
    } else if (!_isAm && displayHour == 12) {
      newHour = 12;
    } else if (!_isAm) {
      newHour += 12;
    }

    setState(() {
      _time = _time.copyWith(hour: newHour);
    });
  }

  void _setMinute(int minute) {
    setState(() {
      _time = _time.copyWith(minute: minute);
    });
  }

  void _setAmPm(bool isAm) {
    setState(() {
      _isAm = isAm;
      int hour = _time.hour;

      if (isAm && hour >= 12) {
        hour -= 12;
      } else if (!isAm && hour < 12) {
        hour += 12;
      }

      _time = _time.copyWith(hour: hour);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = widget.language;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppStrings.text(lang, 'select_time'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildLeftPanel(context)),
                  const SizedBox(width: 20),
                  Expanded(
                    child: SizedBox(
                      width: 260,
                      height: 260,
                      child: _ClockPreview(
                        time: _time,
                        activeUnit: _activeUnit,
                        onHourChanged: _setDisplayHour,
                        onMinuteChanged: _setMinute,
                        onActiveUnitChanged: (unit) =>
                            setState(() => _activeUnit = unit),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppStrings.text(lang, 'cancel')),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, _time),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftPanel(BuildContext context) {
    final theme = Theme.of(context);
    final lang = widget.language;

    return Column(
      children: [
        Row(
          children: [
            _NumberBox(
              label: AppStrings.text(lang, 'hour'),
              value: _displayHour.toString(),
              selected: _activeUnit == PlannerClockUnit.hour,
              onTap: () {
                setState(() {
                  _activeUnit = PlannerClockUnit.hour;
                });
              },
            ),
            const SizedBox(width: 8),
            Text(
              ':',
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 8),
            _NumberBox(
              label: AppStrings.text(lang, 'minute'),
              value: _time.minute.toString().padLeft(2, '0'),
              selected: _activeUnit == PlannerClockUnit.minute,
              onTap: () {
                setState(() {
                  _activeUnit = PlannerClockUnit.minute;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(value: true, label: Text('AM')),
                  ButtonSegment<bool>(value: false, label: Text('PM')),
                ],
                selected: {_isAm},
                onSelectionChanged: (value) {
                  _setAmPm(value.first);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

}

class _ClockPreview extends StatefulWidget {
  const _ClockPreview({
    required this.time,
    required this.activeUnit,
    required this.onHourChanged,
    required this.onMinuteChanged,
    required this.onActiveUnitChanged,
  });

  final PlannerClockTime time;
  final PlannerClockUnit activeUnit;
  final Function(int) onHourChanged;
  final Function(int) onMinuteChanged;
  final Function(PlannerClockUnit) onActiveUnitChanged;

  @override
  State<_ClockPreview> createState() => _ClockPreviewState();
}

class _ClockPreviewState extends State<_ClockPreview> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    // ìœ„/ì˜¤ë¥¸ìª½: í˜„ìž¬ ì„ íƒëœ ë‹¨ìœ„ +1
    if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowRight) {
      if (widget.activeUnit == PlannerClockUnit.hour) {
        final newHour = (widget.time.hour + 1) % 24;
        widget.onHourChanged(newHour % 12 == 0 ? 12 : newHour % 12);
      } else {
        widget.onMinuteChanged((widget.time.minute + 1) % 60);
      }
      return KeyEventResult.handled;
    }

    // ì•„ëž˜/ì™¼ìª½: í˜„ìž¬ ì„ íƒëœ ë‹¨ìœ„ -1
    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowLeft) {
      if (widget.activeUnit == PlannerClockUnit.hour) {
        int newHour = widget.time.hour - 1;
        if (newHour < 0) newHour = 23;
        widget.onHourChanged(newHour % 12 == 0 ? 12 : newHour % 12);
      } else {
        int newMin = widget.time.minute - 1;
        if (newMin < 0) newMin = 59;
        widget.onMinuteChanged(newMin);
      }
      return KeyEventResult.handled;
    }

    // Tab: ì‹œ/ë¶„ ì „í™˜
    if (key == LogicalKeyboardKey.tab) {
      widget.onActiveUnitChanged(
        widget.activeUnit == PlannerClockUnit.hour
            ? PlannerClockUnit.minute
            : PlannerClockUnit.hour,
      );
      return KeyEventResult.handled;
    }

    // ìˆ«ìž í‚¤: ì‹œê°„ ì§ì ‘ ìž…ë ¥
    final digitKeys = {
      LogicalKeyboardKey.digit0: 0,
      LogicalKeyboardKey.digit1: 1,
      LogicalKeyboardKey.digit2: 2,
      LogicalKeyboardKey.digit3: 3,
      LogicalKeyboardKey.digit4: 4,
      LogicalKeyboardKey.digit5: 5,
      LogicalKeyboardKey.digit6: 6,
      LogicalKeyboardKey.digit7: 7,
      LogicalKeyboardKey.digit8: 8,
      LogicalKeyboardKey.digit9: 9,
      LogicalKeyboardKey.numpad0: 0,
      LogicalKeyboardKey.numpad1: 1,
      LogicalKeyboardKey.numpad2: 2,
      LogicalKeyboardKey.numpad3: 3,
      LogicalKeyboardKey.numpad4: 4,
      LogicalKeyboardKey.numpad5: 5,
      LogicalKeyboardKey.numpad6: 6,
      LogicalKeyboardKey.numpad7: 7,
      LogicalKeyboardKey.numpad8: 8,
      LogicalKeyboardKey.numpad9: 9,
    };

    if (digitKeys.containsKey(key)) {
      final digit = digitKeys[key]!;
      if (widget.activeUnit == PlannerClockUnit.hour) {
        widget.onHourChanged(digit == 0 ? 12 : digit);
      } else {
        // 0â†’0ë¶„, 1â†’5ë¶„, 2â†’10ë¶„, ... ìˆ«ìž * 5
        widget.onMinuteChanged((digit * 5) % 60);
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _handleClockInteraction(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);

    final radius = size.width / 2 * 0.84;
    final hourRadius = radius * 0.45;
    final minuteRadius = radius * 0.68;

    // í´ë¦­ ìœ„ì¹˜ê°€ ë¶„ì¹¨ ê¶¤ë„ì— ë” ê°€ê¹Œìš°ë©´ ë¶„, ì‹œì¹¨ ê¶¤ë„ì— ë” ê°€ê¹Œìš°ë©´ ì‹œ
    final PlannerClockUnit unit =
        (distance - minuteRadius).abs() < (distance - hourRadius).abs()
            ? PlannerClockUnit.minute
            : PlannerClockUnit.hour;

    widget.onActiveUnitChanged(unit);

    var angle = math.atan2(dy, dx);
    angle = angle - (-math.pi / 2);

    while (angle < 0) {
      angle += 2 * math.pi;
    }
    while (angle >= 2 * math.pi) {
      angle -= 2 * math.pi;
    }

    if (unit == PlannerClockUnit.hour) {
      int hour = ((angle / (2 * math.pi)) * 12).round();
      if (hour == 0) hour = 12;
      if (hour == 13) hour = 1;
      widget.onHourChanged(hour);
    } else {
      int minute = ((angle / (2 * math.pi)) * 60).round();
      minute = ((minute + 2.5) ~/ 5) * 5;
      if (minute >= 60) minute = 0;
      if (minute < 0) minute = 55;
      widget.onMinuteChanged(minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return Focus(
          focusNode: _focusNode,
          onKeyEvent: _handleKeyEvent,
          child: GestureDetector(
            onTapDown: (details) {
              _focusNode.requestFocus();
              _handleClockInteraction(details.localPosition, size);
            },
            onPanUpdate: (details) {
              _handleClockInteraction(details.localPosition, size);
            },
            child: CustomPaint(
              painter: _ClockPreviewPainter(
                context: context,
                time: widget.time,
                activeUnit: widget.activeUnit,
              ),
              size: size,
            ),
          ),
        );
      },
    );
  }
}

class _ClockPreviewPainter extends CustomPainter {
  _ClockPreviewPainter({
    required this.context,
    required this.time,
    required this.activeUnit,
  });

  final BuildContext context;
  final PlannerClockTime time;
  final PlannerClockUnit activeUnit;

  @override
  void paint(Canvas canvas, Size size) {
    final theme = Theme.of(context);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.84;

    final bgPaint = Paint()
      ..color = theme.colorScheme.surfaceContainerHighest.withOpacity(0.55)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, bgPaint);

    for (int i = 1; i <= 12; i++) {
      final angle = -math.pi / 2 + (i / 12) * math.pi * 2;
      final pos = Offset(
        center.dx + math.cos(angle) * (radius - 24),
        center.dy + math.sin(angle) * (radius - 24),
      );

      final tp = TextPainter(
        text: TextSpan(
          text: '$i',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }

    final hourAngle =
        -math.pi / 2 + ((time.hour % 12) + time.minute / 60) / 12 * math.pi * 2;
    final minuteAngle =
        -math.pi / 2 + (time.minute / 60) * math.pi * 2;

    _drawHand(
      canvas,
      center,
      radius * 0.45,
      hourAngle,
      activeUnit == PlannerClockUnit.hour
          ? theme.colorScheme.primary
          : theme.colorScheme.primary.withOpacity(0.45),
      5,
    );

    _drawHand(
      canvas,
      center,
      radius * 0.68,
      minuteAngle,
      activeUnit == PlannerClockUnit.minute
          ? theme.colorScheme.secondary
          : theme.colorScheme.secondary.withOpacity(0.45),
      3.2,
    );

    final centerOuter = Paint()..color = theme.colorScheme.surface;
    final centerInner = Paint()..color = theme.colorScheme.primary;

    canvas.drawCircle(center, 7, centerOuter);
    canvas.drawCircle(center, 4, centerInner);
  }

  void _drawHand(
    Canvas canvas,
    Offset center,
    double length,
    double angle,
    Color color,
    double strokeWidth,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      center,
      Offset(
        center.dx + math.cos(angle) * length,
        center.dy + math.sin(angle) * length,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ClockPreviewPainter oldDelegate) {
    return oldDelegate.time != time || oldDelegate.activeUnit != activeUnit;
  }
}

class _NumberBox extends StatelessWidget {
  const _NumberBox({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary.withOpacity(0.14)
                : theme.colorScheme.surfaceContainerHighest.withOpacity(0.45),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary.withOpacity(0.8)
                  : theme.colorScheme.outlineVariant.withOpacity(0.6),
            ),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitChip extends StatelessWidget {
  const _UnitChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withOpacity(0.12)
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.55),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary.withOpacity(0.7)
                : theme.colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: selected ? theme.colorScheme.primary : null,
          ),
        ),
      ),
    );
  }
}

class _GridValueButton extends StatelessWidget {
  const _GridValueButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected
              ? theme.colorScheme.primary.withOpacity(0.14)
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.45),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary.withOpacity(0.8)
                : theme.colorScheme.outlineVariant.withOpacity(0.45),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: selected ? theme.colorScheme.primary : null,
            ),
          ),
        ),
      ),
    );
  }
}
