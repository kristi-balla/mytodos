import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/// Example event class.
class Event {
  final String title;
  DateTime date;
  String description;
  Priority? priority;
  DateTime endDate;
  RecurrenceFrequency? frequency;

  Event({
    required this.title,
    required this.date,
    required this.description,
    required this.priority,
    required this.endDate,
    this.frequency,
  });

  @override
  String toString() => title;
}

enum Priority {
  critical('critical', Colors.red),
  important('important', Colors.orange),
  medium('medium', Colors.green),
  low('low', Colors.blue),
  nonExistant('non-existant', Colors.purple);

  const Priority(this.label, this.color);
  final String label;
  final Color color;

  @override
  String toString() => label;
}

enum RecurrenceFrequency {
  once,
  daily,
  weekly,
  monthly,
  yearly,
}

/// Example events.
///
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(Map.from({}));

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

List<Event> generateRecurringEvents(Event event) {
  List<Event> recurringEvents = [];
  DateTime currentDate = event.date;
  recurringEvents.add(event);

  if (event.frequency == RecurrenceFrequency.once) {
    return recurringEvents;
  }

  while (!currentDate.isAfter(event.endDate)) {
    switch (event.frequency) {
      case RecurrenceFrequency.daily:
        currentDate = currentDate.add(const Duration(days: 1));
        break;
      case RecurrenceFrequency.weekly:
        currentDate = currentDate.add(const Duration(days: 7));
        break;
      case RecurrenceFrequency.monthly:
        currentDate =
            DateTime(currentDate.year, currentDate.month + 1, currentDate.day);
        break;
      case RecurrenceFrequency.yearly:
        currentDate =
            DateTime(currentDate.year + 1, currentDate.month, currentDate.day);
        break;
      default:
        break;
    }

    recurringEvents.add(Event(
      title: event.title,
      date: currentDate,
      description: event.description,
      priority: event.priority,
      endDate: event.endDate,
      frequency: event.frequency,
    ));
  }

  return recurringEvents;
}
