import 'package:ai_assistant/features/appointment/domain/provider_availability_override.dart';
import 'package:ai_assistant/features/appointment/domain/provider_weekly_availability.dart';
import 'package:ai_assistant/features/appointment/domain/slot_generator.dart';
import 'package:ai_assistant/features/appointment/domain/time_slot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final generator = SlotGenerator();
  final friday = DateTime.utc(2026, 10, 9);
  final saturday = DateTime.utc(2026, 10, 10);

  final weeklyFriday = ProviderWeeklyAvailability(
    id: 'weekly-fri',
    providerId: 'provider-1',
    dayOfWeek: DateTime.friday,
    openMinutes: 9 * 60,
    closeMinutes: 17 * 60,
  );

  test('opens a normal Friday into duration-sized slots', () {
    final slots = generator.generate(
      rangeStart: friday,
      rangeEnd: saturday,
      durationMinutes: 30,
      weekly: [weeklyFriday],
      overrides: const [],
      busy: const [],
    );

    expect(slots.first.start, DateTime.utc(2026, 10, 9, 9));
    expect(slots.first.end, DateTime.utc(2026, 10, 9, 9, 30));
    expect(slots.last.start, DateTime.utc(2026, 10, 9, 16, 30));
    expect(slots.last.end, DateTime.utc(2026, 10, 9, 17));
    expect(slots, hasLength(16));
  });

  test('returns no slots when Friday is overridden as closed', () {
    final slots = generator.generate(
      rangeStart: friday,
      rangeEnd: saturday,
      durationMinutes: 30,
      weekly: [weeklyFriday],
      overrides: [
        ProviderAvailabilityOverride(
          id: 'off',
          providerId: 'provider-1',
          date: friday,
          isClosed: true,
        ),
      ],
      busy: const [],
    );

    expect(slots, isEmpty);
  });

  test('uses shorter override hours instead of the weekly window', () {
    final slots = generator.generate(
      rangeStart: friday,
      rangeEnd: saturday,
      durationMinutes: 30,
      weekly: [weeklyFriday],
      overrides: [
        ProviderAvailabilityOverride(
          id: 'short',
          providerId: 'provider-1',
          date: friday,
          openMinutes: 9 * 60,
          closeMinutes: 12 * 60,
        ),
      ],
      busy: const [],
    );

    expect(slots.first.start, DateTime.utc(2026, 10, 9, 9));
    expect(slots.last.start, DateTime.utc(2026, 10, 9, 11, 30));
    expect(slots, hasLength(6));
  });

  test('punches a hole around a busy appointment', () {
    final slots = generator.generate(
      rangeStart: friday,
      rangeEnd: saturday,
      durationMinutes: 30,
      weekly: [weeklyFriday],
      overrides: const [],
      busy: [
        TimeSlot(
          start: DateTime.utc(2026, 10, 9, 10),
          end: DateTime.utc(2026, 10, 9, 10, 30),
        ),
      ],
    );

    expect(
      slots.map((slot) => slot.start),
      isNot(contains(DateTime.utc(2026, 10, 9, 10))),
    );
    expect(slots.map((slot) => slot.start), contains(DateTime.utc(2026, 10, 9, 9, 30)));
    expect(slots.map((slot) => slot.start), contains(DateTime.utc(2026, 10, 9, 10, 30)));
  });

  test('drops leftover time shorter than the service duration', () {
    final slots = generator.generate(
      rangeStart: friday,
      rangeEnd: saturday,
      durationMinutes: 30,
      weekly: [
        ProviderWeeklyAvailability(
          id: 'short-day',
          providerId: 'provider-1',
          dayOfWeek: DateTime.friday,
          openMinutes: 9 * 60,
          closeMinutes: 9 * 60 + 20,
        ),
      ],
      overrides: const [],
      busy: const [],
    );

    expect(slots, isEmpty);
  });
}
