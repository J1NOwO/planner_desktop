import 'package:flutter/material.dart';

class PlannerItem {
  final String id;
  final String title;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;
  final int colorValue;

  PlannerItem({
    required this.id,
    required this.title,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.colorValue,
  })  : assert(startHour >= 0 && startHour <= 23, 'startHour must be 0-23'),
        assert(startMinute >= 0 && startMinute <= 59, 'startMinute must be 0-59'),
        assert(endHour >= 0 && endHour <= 23, 'endHour must be 0-23'),
        assert(endMinute >= 0 && endMinute <= 59, 'endMinute must be 0-59');

  int get startTotalMinutes => startHour * 60 + startMinute;
  int get endTotalMinutes => endHour * 60 + endMinute;

  Color get color => Color(colorValue);

  String get startText =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';

  String get endText =>
      '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

  String get rangeText => '$startText - $endText';

  DateTime startDateTimeFor(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      startHour,
      startMinute,
    );
  }

  DateTime endDateTimeFor(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      endHour,
      endMinute,
    );
  }
}