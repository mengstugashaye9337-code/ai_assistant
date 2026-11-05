class BusinessHours {
  final int openMinutes;
  final int closeMinutes;
  final int stepMinutes;

  BusinessHours({
    required this.openMinutes,
    required this.closeMinutes,
    required this.stepMinutes,
  });

  BusinessHours copyWith({
    int? openMinutes,
    int? closeMinutes,
    int? stepMinutes,
  }) {
    return BusinessHours(
      openMinutes: openMinutes ?? this.openMinutes,
      closeMinutes: closeMinutes ?? this.closeMinutes,
      stepMinutes: stepMinutes ?? this.stepMinutes,
    );
  }
}
