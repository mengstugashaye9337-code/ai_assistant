import 'package:ai_assistant/features/service/domain/service.dart';
import 'package:ai_assistant/features/service/infrastructure/repository/supabase_services_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps a valid Supabase row to a Service', () {
    final service = SupabaseServicesMapper.fromSupabase({
      'id': 'service-1',
      'name': 'Consultation',
      'description': 'Initial consultation',
      'price': 50.0,
      'duration_minutes': 30,
    });

    expect(service, isA<Service>());
    expect(service.id, 'service-1');
    expect(service.price, 50.0);
    expect(service.durationMinutes, 30);
  });

  test('rejects rows with missing required fields', () {
    final row = _validRow()..remove('description');

    expect(
      () => SupabaseServicesMapper.fromSupabase(row),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects rows with invalid field types', () {
    final row = _validRow()..['price'] = '50';

    expect(
      () => SupabaseServicesMapper.fromSupabase(row),
      throwsA(isA<FormatException>()),
    );
  });

  test('rejects rows with a missing duration', () {
    final row = _validRow()..remove('duration_minutes');

    expect(
      () => SupabaseServicesMapper.fromSupabase(row),
      throwsA(isA<FormatException>()),
    );
  });

  test('accepts an integral numeric duration', () {
    final row = _validRow()..['duration_minutes'] = 30.0;

    final service = SupabaseServicesMapper.fromSupabase(row);

    expect(service.durationMinutes, 30);
  });
}

Map<String, dynamic> _validRow() {
  return {
    'id': 'service-1',
    'name': 'Consultation',
    'description': 'Initial consultation',
    'price': 50,
    'duration_minutes': 30,
  };
}
