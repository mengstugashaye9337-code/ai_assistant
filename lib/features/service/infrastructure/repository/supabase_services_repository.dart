import 'package:ai_assistant/features/service/domain/service.dart';
import 'package:ai_assistant/features/service/domain/services_repository.dart';
import 'package:ai_assistant/features/service/infrastructure/repository/supabase_services_mapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseServicesRepository implements ServicesRepository {
  final SupabaseClient _client;

  SupabaseServicesRepository({required SupabaseClient client})
    : _client = client;

  @override
  Future<List<Service>> getServices() async {
    final response = await _client.from('services').select();

    return response
        .map((row) => SupabaseServicesMapper.fromSupabase(row))
        .toList();
  }

  @override
  Future<Service?> getServiceById(String id) async {
    final response = await _client
        .from('services')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) {
      throw Exception('Service not found');
    }

    return SupabaseServicesMapper.fromSupabase(response);
  }
}
