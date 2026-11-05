import 'package:ai_assistant/features/appointment/domain/provider_availability_override.dart';
import 'package:ai_assistant/features/appointment/domain/provider_weekly_availability.dart';
import 'package:ai_assistant/features/appointment/domain/time_slot.dart';
import 'package:ai_assistant/core/time/salon_time.dart';

class SlotGenerator {
  List<TimeSlot> generate({
    required DateTime rangeStart,
    required DateTime rangeEnd,
    required int durationMinutes,
    required List<ProviderWeeklyAvailability> weekly,
    required List<ProviderAvailabilityOverride> overrides,
    required List<TimeSlot> busy,
    int? stepMinutes,
  }) {
    if (durationMinutes <= 0) {
      return const [];
    }

    final step = stepMinutes ?? durationMinutes;
    if (step <= 0) {
      return const [];
    }

    final startUtc = rangeStart.toUtc();
    final endUtc = rangeEnd.toUtc();
    if (!endUtc.isAfter(startUtc)) {
      return const [];
    }

    final weeklyByDay = <int, ProviderWeeklyAvailability>{};
    for (final row in weekly) {
      weeklyByDay.putIfAbsent(row.dayOfWeek, () => row);
    }

    final overrideByDate = <String, ProviderAvailabilityOverride>{};
    for (final override in overrides) {
      overrideByDate.putIfAbsent(_dateKey(override.date.toUtc()), () => override);
    }

    final slots = <TimeSlot>[];
    var day = salonDateOf(startUtc);

    while (salonDayStart(day).isBefore(endUtc)) {
      final window = _windowForDay(
        day: day,
        weeklyByDay: weeklyByDay,
        overrideByDate: overrideByDate,
      );
      if (window != null) {
        final free = _subtractBusy(window, busy);
        slots.addAll(
          _slice(
            free: free,
            duration: Duration(minutes: durationMinutes),
            step: Duration(minutes: step),
            notBefore: startUtc,
            notAfter: endUtc,
          ),
        );
      }
      day = day.add(const Duration(days: 1));
    }

    return slots;
  }

  TimeSlot? _windowForDay({
    required DateTime day,
    required Map<int, ProviderWeeklyAvailability> weeklyByDay,
    required Map<String, ProviderAvailabilityOverride> overrideByDate,
  }) {
    final override = overrideByDate[_dateKey(day)];
    if (override != null) {
      if (override.isClosed) {
        return null;
      }
      final open = override.openMinutes;
      final close = override.closeMinutes;
      if (open != null && close != null) {
        return _windowFromMinutes(day, open, close);
      }
    }

    final weekly = weeklyByDay[day.weekday];
    if (weekly == null) {
      return null;
    }
    return _windowFromMinutes(day, weekly.openMinutes, weekly.closeMinutes);
  }

    TimeSlot? _windowFromMinutes(DateTime day, int openMinutes, int closeMinutes) {
    if (closeMinutes <= openMinutes) {
      return null;
    }
    final base = salonDayStart(day);
    return TimeSlot(
      start: base.add(Duration(minutes: openMinutes)),
      end: base.add(Duration(minutes: closeMinutes)),
    );
  }
  List<TimeSlot> _subtractBusy(TimeSlot window, List<TimeSlot> busy) {
    var remaining = <TimeSlot>[window];

    final overlapping = busy.toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    for (final block in overlapping) {
      final next = <TimeSlot>[];
      for (final free in remaining) {
        if (!_overlaps(free, block)) {
          next.add(free);
          continue;
        }
        if (free.start.isBefore(block.start)) {
          next.add(TimeSlot(start: free.start, end: block.start));
        }
        if (block.end.isBefore(free.end)) {
          next.add(TimeSlot(start: block.end, end: free.end));
        }
      }
      remaining = next;
    }

    return remaining;
  }

  bool _overlaps(TimeSlot a, TimeSlot b) {
    return a.start.isBefore(b.end) && b.start.isBefore(a.end);
  }

  List<TimeSlot> _slice({
    required List<TimeSlot> free,
    required Duration duration,
    required Duration step,
    required DateTime notBefore,
    required DateTime notAfter,
  }) {
    final slots = <TimeSlot>[];
    for (final window in free) {
      var start = window.start;
      while (!start.add(duration).isAfter(window.end)) {
        final end = start.add(duration);
        if (!start.isBefore(notBefore) && !end.isAfter(notAfter)) {
          slots.add(TimeSlot(start: start, end: end));
        }
        start = start.add(step);
      }
    }
    return slots;
  }

  String _dateKey(DateTime date) {
    final utc = date.toUtc();
    final month = utc.month.toString().padLeft(2, '0');
    final day = utc.day.toString().padLeft(2, '0');
    return '${utc.year}-$month-$day';
  }
}
