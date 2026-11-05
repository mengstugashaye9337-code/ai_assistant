import 'package:ai_assistant/core/theme/app_spacing.dart';
import 'package:ai_assistant/features/appointment/application/booking_notifier.dart';
import 'package:ai_assistant/features/appointment/application/booking_state.dart';
import 'package:ai_assistant/features/appointment/domain/service_provider.dart';
import 'package:ai_assistant/features/appointment/domain/time_slot.dart';
import 'package:ai_assistant/features/service/domain/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_assistant/core/format/money.dart';
import 'package:ai_assistant/core/time/salon_time.dart';
import 'package:ai_assistant/core/time/salon_time.dart';


class BookingPage extends ConsumerStatefulWidget {
  const BookingPage({required this.service, super.key});

  final Service service;

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(bookingNotifierProvider.notifier).start(widget.service),
    );
  }

  @override
  Widget build(BuildContext context) {
        ref.listen(bookingNotifierProvider, (previous, next) {
      if (next.status is BookingBooked && previous?.status is! BookingBooked) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.service.name} booked')),
        );
        context.pop();
        return;
      }

      final notice = next.notice;
      if (notice != null && notice != previous?.notice) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(notice)),
        );
        ref.read(bookingNotifierProvider.notifier).clearNotice();
      }
    });

    final state = ref.watch(bookingNotifierProvider);
    final days = _upcomingDays();

    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.service.name}')),
      body: switch (state.status) {
        BookingIdle() ||
        BookingLoading() ||
        BookingBooked() => const Center(
          child: CircularProgressIndicator(),
        ),
        BookingError(:final error) => _BookingError(
          error: error,
          onRetry: () =>
              ref.read(bookingNotifierProvider.notifier).start(widget.service),
        ),
        BookingReady() => ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              '${widget.service.durationMinutes} min · ${formatPrice(widget.service.price)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.lg),
            _ProviderPicker(
              providers: state.providers,
              selected: state.selectedProvider,
              onSelected: (provider) => ref
                  .read(bookingNotifierProvider.notifier).selectProvider(provider),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Date', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            _DayPicker(
              days: days,
              selected: state.selectedDay,
              onSelected: (day) =>
                  ref.read(bookingNotifierProvider.notifier).selectDay(day),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Available times', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            if (state.selectedProvider == null)
              const Text('Select a provider to see times.')
            else if (state.slots.isEmpty)
              const Text('No times available on this day.')
            else
              _SlotGrid(
                slots: state.slots,
                selected: state.selectedSlot,
                onSelected: (slot) =>
                    ref.read(bookingNotifierProvider.notifier).selectSlot(slot),
              ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton(
              onPressed: state.selectedSlot == null || state.isSubmitting
                  ? null
                  : () => ref
                        .read(bookingNotifierProvider.notifier)
                        .confirmBooking(),
              child: Text(
                state.isSubmitting ? 'Booking…' : 'Confirm booking',
              ),
            ),
          ],
        ),
      },
    );
  }

   List<DateTime> _upcomingDays() {
    final start = salonToday();
    return List<DateTime>.generate(
      14,
      (index) => start.add(Duration(days: index)),
    );
  }
}

class _ProviderPicker extends StatelessWidget {
  const _ProviderPicker({
    required this.providers,
    required this.selected,
    required this.onSelected,
  });

  final List<ServiceProvider> providers;
  final ServiceProvider? selected;
  final ValueChanged<ServiceProvider> onSelected;

  @override
  Widget build(BuildContext context) {
    if (providers.isEmpty) {
      return const Text('No providers available.');
    }

    if (providers.length == 1) {
      return Text('With ${providers.first.name}');
    }

    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        for (final provider in providers)
          ChoiceChip(
            label: Text(provider.name),
            selected: selected?.id == provider.id,
            onSelected: (_) => onSelected(provider),
          ),
      ],
    );
  }
}

class _DayPicker extends StatelessWidget {
  const _DayPicker({
    required this.days,
    required this.selected,
    required this.onSelected,
  });

  final List<DateTime> days;
  final DateTime? selected;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = selected != null &&
              selected!.year == day.year &&
              selected!.month == day.month &&
              selected!.day == day.day;
          return ChoiceChip(
            label: Text('${day.month}/${day.day}'),
            selected: isSelected,
            onSelected: (_) => onSelected(day),
          );
        },
      ),
    );
  }
}

class _SlotGrid extends StatelessWidget {
  const _SlotGrid({
    required this.slots,
    required this.selected,
    required this.onSelected,
  });

  final List<TimeSlot> slots;
  final TimeSlot? selected;
  final ValueChanged<TimeSlot> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final slot in slots)
          ChoiceChip(
            label: Text(_formatTime(slot.start)),
            selected:
                selected?.start == slot.start && selected?.end == slot.end,
            onSelected: (_) => onSelected(slot),
          ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    final local =  toSalonTime(time);
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _BookingError extends StatelessWidget {
  const _BookingError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Could not load booking times.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('$error', textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
