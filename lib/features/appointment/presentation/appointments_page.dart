 import 'package:ai_assistant/core/theme/app_spacing.dart';
import 'package:ai_assistant/features/appointment/application/appointments_notifier.dart';
import 'package:ai_assistant/features/appointment/application/appointments_state.dart';
import 'package:ai_assistant/features/appointment/domain/appointment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_assistant/core/theme/app_colors.dart';
import 'package:ai_assistant/core/time/salon_time.dart';
import 'package:ai_assistant/features/service/infrastructure/provider/local_first_services_provider.dart';
import 'package:go_router/go_router.dart';


class AppointmentsPage extends ConsumerStatefulWidget {
  const AppointmentsPage({super.key});
 
  @override
  ConsumerState<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends ConsumerState<AppointmentsPage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(appointmentsNotifierProvider.notifier).loadAppointments(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My appointments')),
      body: switch (state.status) {
        AppointmentsIdle() || AppointmentsLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
        AppointmentsError(:final error) => _AppointmentsError(
          error: error,
          onRetry: () => ref
              .read(appointmentsNotifierProvider.notifier)
              .loadAppointments(),
        ),
        AppointmentsLoaded() => _AppointmentsList(
          appointments: state.appointments,
          onCancel: (appointment) => _confirmCancel(context, appointment),
           onBook: _bookAgain,
        ),
      },
    );
  }


  Future<void> _bookAgain(Appointment appointment) async {
  try {
    final service = await ref
        .read(servicesRepositoryProvider)
        .getServiceById(appointment.serviceId);

    if (!mounted) return;

    if (service == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This service is no longer available.')),
      );
      return;
    }

    context.push('/services/${service.id}/book', extra: service);
  } catch (_) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open booking. Try again.')),
    );
  }
}

  Future<void> _confirmCancel(
    BuildContext context,
    Appointment appointment,
  ) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel appointment?'),
          content: Text(
            'Cancel ${appointment.serviceName} on ${_formatDateTime(appointment.startsAt)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Keep'),
            ),
            FilledButton(
              
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),

              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Cancel booking'),
            ),
          ],
        );
      },
    );

    if (shouldCancel == true) {
      await ref
          .read(appointmentsNotifierProvider.notifier)
          .cancelAppointment(appointment.id);
    }
  }
}

class _AppointmentsList extends StatelessWidget {
  const _AppointmentsList({
    required this.appointments,
    required this.onCancel,
    required this.onBook,
  });

  final List<Appointment> appointments;
  final ValueChanged<Appointment> onCancel;
  final ValueChanged<Appointment> onBook;

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return const Center(child: Text('You have no appointments yet.'));
    }

    final now = DateTime.now().toUtc();
    bool isUpcoming(Appointment a) =>
        a.status == AppointmentStatus.confirmed && a.endsAt.isAfter(now);

    final upcoming = appointments.where(isUpcoming).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt)); // soonest first

    final others = appointments.where((a) => !isUpcoming(a)).toList()
      ..sort((a, b) => b.startsAt.compareTo(a.startsAt)); // newest first

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (upcoming.isNotEmpty) ...[
          const _SectionTitle('Upcoming'),
          for (final appointment in upcoming)
            _AppointmentCard(appointment: appointment, onCancel: onCancel, onBook: onBook),
        ],
        if (others.isNotEmpty) ...[
          const _SectionTitle('Past and cancelled'),
          for (final appointment in others)
            _AppointmentCard(appointment: appointment, onCancel: onCancel, onBook: onBook),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

// Step 1: this is your old card code, moved here unchanged.
// We redesign it in step 2.
class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment, this.onCancel, this.onBook});

  final Appointment appointment;
  final ValueChanged<Appointment>? onCancel;
  final ValueChanged<Appointment>? onBook; // null = no book button

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cancelled = appointment.status == AppointmentStatus.cancelled;
    final ended = appointment.endsAt.isBefore(DateTime.now().toUtc());

    // One place decides the label and color from the data.
    final (label, color) = cancelled
        ? ('Cancelled', AppColors.error)
        : ended
            ? ('Completed', AppColors.textSecondary)
            : ('Confirmed', AppColors.success);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      appointment.serviceName,
                      style: textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _StatusChip(label: label, color: color),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('with ${appointment.providerName}', style: textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xs),
              Text(_formatDateTime(appointment.startsAt), style: textTheme.bodyMedium),
                            if (onCancel != null || onBook != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onBook != null)
                      TextButton(
                        onPressed: () => onBook!(appointment),
                        child: const Text('Book again'),
                      ),
                    if (onCancel != null)
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        onPressed: () => onCancel!(appointment),
                        child: const Text('Cancel'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
      ),
    );
  }
}




class _AppointmentsError extends StatelessWidget {
  const _AppointmentsError({required this.error, required this.onRetry});

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
              'Could not load appointments.',
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

String _formatDateTime(DateTime value) {
  final local = toSalonTime(value);
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.year}-$month-$day $hour:$minute';
}
