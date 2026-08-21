class Conversation {
  final String? id;
  final String userId;
  final String? title;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Conversation({
    this.id,
    required this.userId,
    this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  Conversation copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
