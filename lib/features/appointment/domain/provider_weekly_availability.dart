class ProviderWeeklyAvailability {
  final String id;
  final String providerId;
  final int dayOfWeek;

  final int openMinutes;
  final int closeMinutes;

  ProviderWeeklyAvailability({
    required this.id,
    required this.providerId,
    required this.dayOfWeek,
    required this.openMinutes,
    required this.closeMinutes,
  });
}
