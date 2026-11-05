enum AppointmentStatus { confirmed, cancelled }

class Appointment {
  
  final String id;

  final String customerId;
  final String providerId;
  final String serviceId;
  final String providerName;

  final DateTime startsAt;
  final DateTime endsAt;

  final int durationMinutes;
  final num price;
  final String serviceName;

  final AppointmentStatus status;

  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.customerId,
    required this.serviceId,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.serviceName,
    required this.durationMinutes,
    required this.price,
    required this.createdAt,
    required this.providerId,
    required this.providerName,
  });

  Appointment copyWith({
    String? id,
    String? customerId,
    String? serviceId,
    DateTime? startsAt,
    DateTime? endsAt,
    AppointmentStatus? status,
    String? serviceName,
    int? durationMinutes,
    num? price,
    DateTime? createdAt,
    String? providerId,
    String? providerName,
  }) {
    return Appointment(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      serviceId: serviceId ?? this.serviceId,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      status: status ?? this.status,
      serviceName: serviceName ?? this.serviceName,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      price: price ?? this.price,
      createdAt: createdAt?? this.createdAt,
      providerId: providerId?? this.providerId,
      providerName: providerName ?? this.providerName,
    );
  }
}
