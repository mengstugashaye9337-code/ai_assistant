class Service {
  final String id;
  final String name;
  final String description;
  final num price;
  final int durationMinutes;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
  });

  Service copyWith({
    String? id,
    String? name,
    String? description,
    num? price,
    int? durationMinutes,
  }) {
    return Service(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }
}
