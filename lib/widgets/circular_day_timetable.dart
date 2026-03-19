import 'dart:math' as math;
import 'package:flutter/material.dart';

class CircularDayTimetable<T> extends StatelessWidget {
  const CircularDayTimetable({
    super.key,
    required this.items,
    required this.startDateTimeBuilder,
    required this.endDateTimeBuilder,
    required this.colorBuilder,
    this.size = 240,
  });

  final List<T> items;
  final DateTime Function(T item) startDateTimeBuilder;
  final DateTime Function(T item) endDateTimeBuilder;
  final Color Function(T item) colorBuilder;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CircularDayTimetablePainter<T>(
          context: context,
          items: items,
          startDateTimeBuilder: startDateTimeBuilder,
          endDateTimeBuilder: endDateTimeBuilder,
          colorBuilder: colorBuilder,
        ),
      ),
    );
  }
}

class AnalogLiveClock extends StatelessWidget {
  const AnalogLiveClock({
    super.key,
    required this.now,
    required this.timeZoneLabel,
    this.size = 240,
  });

  final DateTime now;
  final String timeZoneLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _AnalogLiveClockPainter(
              context: context,
              now: now,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          timeZoneLabel,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _CircularDayTimetablePainter<T> extends CustomPainter {
  _CircularDayTimetablePainter({
    required this.context,
    required this.items,
    required this.startDateTimeBuilder,
    required this.endDateTimeBuilder,
    required this.colorBuilder,
  });

  final BuildContext context;
  final List<T> items;
  final DateTime Function(T item) startDateTimeBuilder;
  final DateTime Function(T item) endDateTimeBuilder;
  final Color Function(T item) colorBuilder;

  @override
  void paint(Canvas canvas, Size size) {
    final theme = Theme.of(context);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final faceRadius = radius * 0.72;
    final labelRadius = radius * 0.90;

    final facePaint = Paint()
      ..color = theme.colorScheme.surfaceContainerHighest.withOpacity(0.45)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = theme.colorScheme.outlineVariant.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(center, faceRadius, facePaint);
    canvas.drawCircle(center, faceRadius, borderPaint);

    _drawHourTicks(canvas, center, faceRadius, theme);
    _drawHourLabels(canvas, center, labelRadius, theme);
    _drawScheduleArcs(canvas, center, faceRadius);
  }

  void _drawHourTicks(
    Canvas canvas,
    Offset center,
    double radius,
    ThemeData theme,
  ) {
    final paint = Paint()
      ..color = theme.colorScheme.outline.withOpacity(0.18)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    for (int hour = 0; hour < 24; hour++) {
      final angle = _angleForFraction(hour / 24);
      final outer = Offset(
        center.dx + math.cos(angle) * (radius + 3),
        center.dy + math.sin(angle) * (radius + 3),
      );
      final inner = Offset(
        center.dx + math.cos(angle) * (radius - 14),
        center.dy + math.sin(angle) * (radius - 14),
      );
      canvas.drawLine(inner, outer, paint);
    }
  }

  void _drawHourLabels(
    Canvas canvas,
    Offset center,
    double radius,
    ThemeData theme,
  ) {
    for (int hour = 0; hour < 24; hour++) {
      final angle = _angleForFraction(hour / 24);
      final pos = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );

      final painter = TextPainter(
        text: TextSpan(
          text: hour.toString().padLeft(2, '0'),
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.78),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      painter.paint(
        canvas,
        Offset(pos.dx - painter.width / 2, pos.dy - painter.height / 2),
      );
    }
  }

  void _drawScheduleArcs(Canvas canvas, Offset center, double radius) {
    for (final item in items) {
      final start = startDateTimeBuilder(item);
      final end = endDateTimeBuilder(item);
      final color = colorBuilder(item);

      final startFraction = (start.hour + start.minute / 60) / 24.0;
      final endFraction = (end.hour + end.minute / 60) / 24.0;

      final segments = endFraction < startFraction
          ? [(startFraction, 1.0), (0.0, endFraction)]
          : [(startFraction, endFraction)];

      for (final seg in segments) {
        final rect = Rect.fromCircle(center: center, radius: radius - 12);

        final fillPaint = Paint()
          ..color = color.withOpacity(0.18)
          ..style = PaintingStyle.fill;

        final strokePaint = Paint()
          ..color = color.withOpacity(0.90)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round;

        final startAngle = _angleForFraction(seg.$1);
        final sweep = (seg.$2 - seg.$1) * math.pi * 2;

        final path = Path()
          ..moveTo(center.dx, center.dy)
          ..arcTo(rect, startAngle, sweep, false)
          ..close();

        canvas.drawPath(path, fillPaint);
        canvas.drawArc(rect, startAngle, sweep, false, strokePaint);
      }
    }
  }

  double _angleForFraction(double fraction) {
    return -math.pi / 2 + fraction * math.pi * 2;
  }

  @override
  bool shouldRepaint(covariant _CircularDayTimetablePainter<T> oldDelegate) {
    if (oldDelegate.items.length != items.length) return true;
    for (int i = 0; i < items.length; i++) {
      if (oldDelegate.items[i] != items[i]) return true;
    }
    return false;
  }
}

class _AnalogLiveClockPainter extends CustomPainter {
  _AnalogLiveClockPainter({
    required this.context,
    required this.now,
  });

  final BuildContext context;
  final DateTime now;

  @override
  void paint(Canvas canvas, Size size) {
    final theme = Theme.of(context);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final faceRadius = radius * 0.72;
    final labelRadius = radius * 0.90;

    final facePaint = Paint()
      ..color = theme.colorScheme.surfaceContainerHighest.withOpacity(0.45)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = theme.colorScheme.outlineVariant.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(center, faceRadius, facePaint);
    canvas.drawCircle(center, faceRadius, borderPaint);

    _drawTicks(canvas, center, faceRadius, theme);
    _drawLabels(canvas, center, labelRadius, theme);
    _drawHands(canvas, center, faceRadius, theme);
    _drawCenterDot(canvas, center, theme);
  }

  void _drawTicks(Canvas canvas, Offset center, double radius, ThemeData theme) {
    final minorPaint = Paint()
      ..color = theme.colorScheme.outline.withOpacity(0.08)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    final majorPaint = Paint()
      ..color = theme.colorScheme.outline.withOpacity(0.18)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 60; i++) {
      final angle = -math.pi / 2 + (i / 60) * math.pi * 2;
      final isMajor = i % 5 == 0;

      final outer = Offset(
        center.dx + math.cos(angle) * (radius + 1),
        center.dy + math.sin(angle) * (radius + 1),
      );
      final inner = Offset(
        center.dx + math.cos(angle) * (isMajor ? radius - 14 : radius - 8),
        center.dy + math.sin(angle) * (isMajor ? radius - 14 : radius - 8),
      );

      canvas.drawLine(inner, outer, isMajor ? majorPaint : minorPaint);
    }
  }

  void _drawLabels(
    Canvas canvas,
    Offset center,
    double radius,
    ThemeData theme,
  ) {
    const labels = ['12', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11'];

    for (int i = 0; i < 12; i++) {
      final angle = -math.pi / 2 + (i / 12) * math.pi * 2;
      final pos = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );

      final painter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.78),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      painter.paint(
        canvas,
        Offset(pos.dx - painter.width / 2, pos.dy - painter.height / 2),
      );
    }
  }

  void _drawHands(Canvas canvas, Offset center, double radius, ThemeData theme) {
    final hourFraction =
        ((now.hour % 12) + now.minute / 60 + now.second / 3600) / 12.0;
    final minuteFraction = (now.minute + now.second / 60) / 60.0;
    final secondFraction = now.second / 60.0;

    final hourAngle = -math.pi / 2 + hourFraction * math.pi * 2;
    final minuteAngle = -math.pi / 2 + minuteFraction * math.pi * 2;
    final secondAngle = -math.pi / 2 + secondFraction * math.pi * 2;

    final hourPaint = Paint()
      ..color = theme.colorScheme.primary
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final minutePaint = Paint()
      ..color = theme.colorScheme.secondary
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    final secondPaint = Paint()
      ..color = theme.colorScheme.error
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      center,
      Offset(
        center.dx + math.cos(hourAngle) * radius * 0.42,
        center.dy + math.sin(hourAngle) * radius * 0.42,
      ),
      hourPaint,
    );

    canvas.drawLine(
      center,
      Offset(
        center.dx + math.cos(minuteAngle) * radius * 0.62,
        center.dy + math.sin(minuteAngle) * radius * 0.62,
      ),
      minutePaint,
    );

    canvas.drawLine(
      center,
      Offset(
        center.dx + math.cos(secondAngle) * radius * 0.76,
        center.dy + math.sin(secondAngle) * radius * 0.76,
      ),
      secondPaint,
    );
  }

  void _drawCenterDot(Canvas canvas, Offset center, ThemeData theme) {
    final outerPaint = Paint()..color = theme.colorScheme.surface;
    final innerPaint = Paint()..color = theme.colorScheme.primary;

    canvas.drawCircle(center, 6, outerPaint);
    canvas.drawCircle(center, 3.5, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _AnalogLiveClockPainter oldDelegate) {
    return oldDelegate.now.second != now.second;
  }
}