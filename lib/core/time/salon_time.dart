/// Africa/Addis_Ababa: UTC+3, no daylight saving.
const Duration salonUtcOffset = Duration(hours: 3);

/// A real instant as salon wall-clock time (read .hour, .minute etc. from it).
DateTime toSalonTime(DateTime instant) => instant.toUtc().add(salonUtcOffset);

/// The salon's calendar date for an instant, as DateTime.utc(y, m, d).
DateTime salonDateOf(DateTime instant) {
  final local = toSalonTime(instant);
  return DateTime.utc(local.year, local.month, local.day);
}

DateTime salonToday() => salonDateOf(DateTime.now());

/// The real UTC instant when that salon date starts (00:00 salon time).
DateTime salonDayStart(DateTime dateKey) =>
    DateTime.utc(dateKey.year, dateKey.month, dateKey.day)
        .subtract(salonUtcOffset);