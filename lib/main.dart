import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../utils.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const TodoScreen(),
      },
    );
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _currentIndex == 0
            ? const Text('Calendar')
            : const Text('Todo List'),
      ),
      body:
          _currentIndex == 0 ? const CalendarScreen() : const TodoListScreen(),
      floatingActionButton: _currentIndex == 0 ? const AddEventButton() : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted),
            label: 'Todos',
          ),
        ],
      ),
    );
  }
}

class AddEventButton extends StatelessWidget {
  const AddEventButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) => const AddEventDialog(),
        );
      },
      child: const Icon(Icons.add),
    );
  }
}

class AddEventDialog extends StatefulWidget {
  const AddEventDialog({super.key});

  @override
  _AddEventDialogState createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _eventNameController = TextEditingController();
  late DateTime _selectedDate;
  final _eventDescriptionController = TextEditingController();
  final _eventPriorityController = TextEditingController();
  Priority? selectedPriority;
  late DateTime _selectedEndDate;
  final _eventFrequencyController = TextEditingController();
  RecurrenceFrequency? selectedFrequency;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedEndDate = DateTime.now();
  }

  Future<DateTime> _pickDateTime(
      BuildContext context, DateTime initDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initDate),
      );
      if (pickedTime != null) {
        return DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }

    return initDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Event'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _eventNameController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Start Date: '),
              Text(DateFormat('yyyy-MM-dd HH:mm').format(_selectedDate)),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final date = await _pickDateTime(context, _selectedDate);
                  setState(() {
                    _selectedDate = date;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _eventDescriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(height: 20),
          DropdownMenu<Priority>(
            initialSelection: Priority.nonExistant,
            controller: _eventPriorityController,
            // requestFocusOnTap is enabled/disabled by platforms when it is null.
            // On mobile platforms, this is false by default. Setting this to true will
            // trigger focus request on the text field and virtual keyboard will appear
            // afterward. On desktop platforms however, this defaults to true.
            requestFocusOnTap: true,
            label: const Text('Priority'),
            onSelected: (Priority? prio) {
              setState(() {
                selectedPriority = prio;
              });
            },
            dropdownMenuEntries: Priority.values
                .map<DropdownMenuEntry<Priority>>((Priority color) {
              return DropdownMenuEntry<Priority>(
                value: color,
                label: color.label,
                enabled: color.label != 'Grey',
                style: MenuItemButton.styleFrom(
                  foregroundColor: color.color,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('End Date: '),
              Text(DateFormat('yyyy-MM-dd HH:mm').format(_selectedEndDate)),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final date = await _pickDateTime(context, _selectedEndDate);
                  setState(() {
                    _selectedEndDate = date;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          DropdownMenu<RecurrenceFrequency>(
            initialSelection: RecurrenceFrequency.never,
            controller: _eventFrequencyController,
            // requestFocusOnTap is enabled/disabled by platforms when it is null.
            // On mobile platforms, this is false by default. Setting this to true will
            // trigger focus request on the text field and virtual keyboard will appear
            // afterward. On desktop platforms however, this defaults to true.
            requestFocusOnTap: true,
            label: const Text('Recurrence Frequency:'),
            onSelected: (RecurrenceFrequency? frequency) {
              setState(() {
                selectedFrequency = frequency;
              });
            },
            dropdownMenuEntries: RecurrenceFrequency.values
                .map<DropdownMenuEntry<RecurrenceFrequency>>(
                    (RecurrenceFrequency freq) {
              return DropdownMenuEntry<RecurrenceFrequency>(
                value: freq,
                label: freq.name,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            final eventName = _eventNameController.text.trim();
            final description = _eventDescriptionController.text.trim();
            if (eventName.isNotEmpty &&
                description.isNotEmpty &&
                selectedPriority != null &&
                selectedFrequency != null) {
              // Add the event to the calendar
              final recurringEvent = Event(
                  title: eventName,
                  date: _selectedDate,
                  description: description,
                  priority: selectedPriority,
                  endDate: _selectedEndDate,
                  frequency: selectedFrequency);

              List<Event> events = generateRecurringEvents(recurringEvent);
              for (Event event in events) {
                kEvents.update(
                  event.date,
                  (events) => events..add(event),
                  ifAbsent: () => [event],
                );
              }

              Navigator.of(context).pop(); // Close the dialog
            }
          },
          child: const Text('Add'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    super.dispose();
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  final Set<DateTime> _selectedDays = LinkedHashSet<DateTime>(
    equals: isSameDay,
    hashCode: getHashCode,
  );

  late PageController _pageController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();

    _selectedDays.add(_focusedDay.value);
    _selectedEvents = ValueNotifier(_getEventsForDay(_focusedDay.value));
  }

  @override
  void dispose() {
    _focusedDay.dispose();
    _selectedEvents.dispose();
    super.dispose();
  }

  bool get canClearSelection =>
      _selectedDays.isNotEmpty || _rangeStart != null || _rangeEnd != null;

  List<Event> _getEventsForDay(DateTime day) {
    kEvents[day]?.sort((ev1, ev2) => ev1.date.compareTo(ev2.date));
    return kEvents[day] ?? [];
  }

  List<Event> _getEventsForDays(Iterable<DateTime> days) {
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    final days = daysInRange(start, end);
    return _getEventsForDays(days);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      if (_selectedDays.contains(selectedDay)) {
        _selectedDays.remove(selectedDay);
      } else {
        _selectedDays.add(selectedDay);
      }

      _focusedDay.value = focusedDay;
      _rangeStart = null;
      _rangeEnd = null;
      _rangeSelectionMode = RangeSelectionMode.toggledOff;
    });

    _selectedEvents.value = _getEventsForDays(_selectedDays);
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _focusedDay.value = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _selectedDays.clear();
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ValueListenableBuilder<DateTime>(
            valueListenable: _focusedDay,
            builder: (context, value, _) {
              return _CalendarHeader(
                focusedDay: value,
                clearButtonVisible: canClearSelection,
                onTodayButtonTap: () {
                  setState(() => _focusedDay.value = DateTime.now());
                },
                onClearButtonTap: () {
                  setState(() {
                    _rangeStart = null;
                    _rangeEnd = null;
                    _selectedDays.clear();
                    _selectedEvents.value = [];
                  });
                },
                onLeftArrowTap: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
                onRightArrowTap: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
              );
            },
          ),
          TableCalendar<Event>(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay.value,
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableGestures: AvailableGestures.all,
            weekendDays: const [DateTime.saturday, DateTime.sunday],
            headerVisible: true,
            selectedDayPredicate: (day) => _selectedDays.contains(day),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            eventLoader: _getEventsForDay,
            calendarBuilders: CalendarBuilders(
              // make the calendar entries squares
              defaultBuilder: (context, day, focusedDay) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  width: 40, // Adjust the width to make it square
                  height: 40, // Adjust the height to make it square
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle, // Set the shape to square
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.blue, // Adjust color as needed
                  ),
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(
                        color: Colors.black), // Adjust text color
                  ),
                );
              },
            ),
            onDaySelected: _onDaySelected,
            onRangeSelected: _onRangeSelected,
            onCalendarCreated: (controller) => _pageController = controller,
            onPageChanged: (focusedDay) => _focusedDay.value = focusedDay,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() => _calendarFormat = format);
              }
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final event = value[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text('Priority: ${event.priority}'),
                            Text(event.description),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                // Implement remove functionality here
                                setState(() {
                                  // Remove the event from the list of events being displayed
                                  value.removeAt(index);
                                  // Update the list of events in the database or wherever they are stored
                                  final eventDate = event.date;
                                  if (kEvents.containsKey(eventDate)) {
                                    // Remove the event from the list associated with the event date
                                    kEvents[eventDate]!.remove(event);
                                    // If the list of events for that date is empty, remove the date entry
                                    if (kEvents[eventDate]!.isEmpty) {
                                      kEvents.remove(eventDate);
                                    }
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final VoidCallback onLeftArrowTap;
  final VoidCallback onRightArrowTap;
  final VoidCallback onTodayButtonTap;
  final VoidCallback onClearButtonTap;
  final bool clearButtonVisible;

  const _CalendarHeader({
    required this.focusedDay,
    required this.onLeftArrowTap,
    required this.onRightArrowTap,
    required this.onTodayButtonTap,
    required this.onClearButtonTap,
    required this.clearButtonVisible,
  });

  @override
  Widget build(BuildContext context) {
    final headerText = DateFormat.yMMM().format(focusedDay);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          const SizedBox(width: 16.0),
          SizedBox(
            width: 120.0,
            child: Text(
              headerText,
              style: const TextStyle(fontSize: 26.0),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today, size: 20.0),
            visualDensity: VisualDensity.compact,
            onPressed: onTodayButtonTap,
          ),
          if (clearButtonVisible)
            IconButton(
              icon: const Icon(Icons.clear, size: 20.0),
              visualDensity: VisualDensity.compact,
              onPressed: onClearButtonTap,
            ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onLeftArrowTap,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: onRightArrowTap,
          ),
        ],
      ),
    );
  }
}

class TodoListScreen extends StatelessWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Todo List Screen'),
    );
  }
}
