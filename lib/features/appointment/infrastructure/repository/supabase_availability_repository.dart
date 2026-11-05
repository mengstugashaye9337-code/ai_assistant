import 'package:ai_assistant/features/appointment/domain/availability_repository.dart';
import 'package:ai_assistant/features/appointment/domain/provider_availability_override.dart';
import 'package:ai_assistant/features/appointment/domain/provider_weekly_availability.dart';
import 'package:ai_assistant/features/appointment/domain/service_provider.dart';
import 'package:ai_assistant/features/appointment/infrastructure/repository/supabase_availability_mapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAvailabilityRepository implements AvailabilityRepository {
  final SupabaseClient _client;

  SupabaseAvailabilityRepository({required SupabaseClient client})
    : _client = client;

  @override
  Future<List<ServiceProvider>> getProviders() async {
    final response = await _client.from('providers').select().order('name');
    return response
        .map((row) => SupabaseAvailabilityMapper.providerFromSupabase(row))
        .toList();
  }

  @override
  Future<List<ProviderWeeklyAvailability>> getWeeklyAvailability(
    String providerId,
  ) async {
    final response = await _client
        .from('provider_weekly_availability')
        .select()
        .eq('provider_id', providerId)
        .eq('is_active', true)
        .order('day_of_week');

    return response
        .map((row) => SupabaseAvailabilityMapper.weeklyFromSupabase(row))
        .toList();
  }

  @override
  Future<List<ProviderAvailabilityOverride>> getOverrides({
    required String providerId,
    required DateTime from,
    required DateTime to,
  }) async {
    final response = await _client
        .from('provider_availability_overrides')
        .select()
        .eq('provider_id', providerId)
        .eq('is_active', true)
        .gte('date', _dateOnly(from.toUtc()))
        .lt('date', _dateOnly(to.toUtc()))
        .order('date');

    return response
        .map((row) => SupabaseAvailabilityMapper.overrideFromSupabase(row))
        .toList();
  }

  String _dateOnly(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
