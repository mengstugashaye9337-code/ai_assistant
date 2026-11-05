import 'package:ai_assistant/features/appointment/domain/provider_availability_override.dart';
import 'package:ai_assistant/features/appointment/domain/provider_weekly_availability.dart';
import 'package:ai_assistant/features/appointment/domain/service_provider.dart';

abstract class AvailabilityRepository {
  Future<List<ServiceProvider>> getProviders();

  Future<List<ProviderWeeklyAvailability>> getWeeklyAvailability(
    String providerId,
  );

  Future<List<ProviderAvailabilityOverride>> getOverrides({
    required String providerId,
    required DateTime from,
    required DateTime to,
  });
}
