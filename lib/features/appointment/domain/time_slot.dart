class TimeSlot {
  final DateTime start;
  final DateTime end;

  TimeSlot({
    required this.start,
    required this.end,
  });

  TimeSlot copyWith({
    DateTime? start,
    DateTime? end,
  }) {
    return TimeSlot(
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }
}
