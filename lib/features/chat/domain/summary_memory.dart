class SummaryMemory {
  final String? summary;
  final int summarizedCount;
  SummaryMemory({this.summary, this.summarizedCount = 0});

  SummaryMemory copyWith({String? summary, int? summarizedCount}) {
    return SummaryMemory(
      summary: summary ?? this.summary,
      summarizedCount: summarizedCount ?? this.summarizedCount,
    );
  }
}
