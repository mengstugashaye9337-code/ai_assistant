import 'package:ai_assistant/features/appointment/infrastructure/repository/supabase_availability_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps a provider row', () {
    final provider = SupabaseAvailabilityMapper.providerFromSupabase({
      'id': 'provider-1',
      'name': 'Alex',
    });

    expect(provider.id, 'provider-1');
    expect(provider.name, 'Alex');
  });

  test('maps weekly availability', () {
    final weekly = SupabaseAvailabilityMapper.weeklyFromSupabase({
      'id': 'weekly-1',
      'provider_id': 'provider-1',
      'day_of_week': 5,
      'open_minutes': 540,
      'close_minutes': 1020,
    });

    expect(weekly.dayOfWeek, 5);
    expect(weekly.openMinutes, 540);
    expect(weekly.closeMinutes, 1020);
  });

  test('maps a closed override date as UTC calendar day', () {
    final override = SupabaseAvailabilityMapper.overrideFromSupabase({
      'id': 'override-1',
      'provider_id': 'provider-1',
      'date': '2026-10-09',
      'open_minutes': null,
      'close_minutes': null,
      'is_closed': true,
    });

    expect(override.date, DateTime.utc(2026, 10, 9));
    expect(override.isClosed, isTrue);
    expect(override.openMinutes, isNull);
  });
}
