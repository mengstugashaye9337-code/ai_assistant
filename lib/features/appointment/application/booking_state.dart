import 'package:ai_assistant/features/appointment/domain/service_provider.dart';
import 'package:ai_assistant/features/appointment/domain/time_slot.dart';
import 'package:ai_assistant/features/service/domain/service.dart';

sealed class BookingStatus {
  const BookingStatus();
}

class BookingIdle extends BookingStatus {
  const BookingIdle();
}

class BookingLoading extends BookingStatus {
  const BookingLoading();
}

class BookingReady extends BookingStatus {
  const BookingReady();
}

class BookingBooked extends BookingStatus {
  const BookingBooked();
}

class BookingError extends BookingStatus {
  final Object error;
  final StackTrace stackTrace;

  const BookingError({required this.error, required this.stackTrace});
}

class BookingState {
  final Service? service;
  final List<ServiceProvider> providers;
  final ServiceProvider? selectedProvider;
  final DateTime? selectedDay;
  final List<TimeSlot> slots;
  final TimeSlot? selectedSlot;
  final bool isSubmitting;
  final BookingStatus status;
  final String? notice; 

  const BookingState({
    required this.service,
    required this.providers,
    required this.selectedProvider,
    required this.selectedDay,
    required this.slots,
    required this.selectedSlot,
    required this.isSubmitting,
    required this.status,
    this.notice,
  });

  factory BookingState.initial() {
    return const BookingState(
      service: null,
      providers: [],
      selectedProvider: null,
      selectedDay: null,
      slots: [],
      selectedSlot: null,
      isSubmitting: false,
      status: BookingIdle(),
      notice: null,
    );
  }

  BookingState copyWith({
    Service? service,
    List<ServiceProvider>? providers,
    ServiceProvider? selectedProvider,
    DateTime? selectedDay,
    List<TimeSlot>? slots,
    TimeSlot? selectedSlot,
    bool? isSubmitting,
    BookingStatus? status,
    String? notice,
    bool clearSelectedProvider = false,
    bool clearSelectedDay = false,
    bool clearSelectedSlot = false,
    bool clearNotice = false,
  }) {
    return BookingState(
      service: service ?? this.service,
      providers: providers ?? this.providers,
      selectedProvider: clearSelectedProvider
          ? null
          : (selectedProvider ?? this.selectedProvider),
      selectedDay: clearSelectedDay ? null : (selectedDay ?? this.selectedDay),
      slots: slots ?? this.slots,
      selectedSlot: clearSelectedSlot
          ? null
          : (selectedSlot ?? this.selectedSlot),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      status: status ?? this.status,
      notice: clearNotice ? null : (notice ?? this.notice),
    );
  }
}
