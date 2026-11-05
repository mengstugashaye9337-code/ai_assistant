class ProviderAvailabilityOverride {
  final String id;
  final String providerId;
  final DateTime date;

  final int? openMinutes;
  final int? closeMinutes;
  final bool isClosed;

  ProviderAvailabilityOverride({
    required this.id,
    required this.providerId,
    required this.date,
    this.openMinutes,
    this.closeMinutes,
    this.isClosed = false,
  });
}
