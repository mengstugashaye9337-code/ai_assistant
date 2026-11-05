import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_assistant/core/theme/app_spacing.dart';
import 'package:ai_assistant/features/service/domain/service.dart';
class ServiceDetailPage extends StatelessWidget {
  const ServiceDetailPage({required this.service, super.key});

  final Service service;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(service.name)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _ServiceDetailHeader(service: service),
          const SizedBox(height: AppSpacing.lg),
          _ServiceDetailDescription(description: service.description),
          const SizedBox(height: AppSpacing.lg),
          _ServiceDetailFacts(service: service),
          const SizedBox(height: AppSpacing.xl),
          _ServiceDetailAction(service: service),
        ],
      ),
    );
  }
}

class _ServiceDetailHeader extends StatelessWidget {
  const _ServiceDetailHeader({required this.service});

  final Service service;

  @override
  Widget build(BuildContext context) {
    return Text(
      service.name,
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}

class _ServiceDetailDescription extends StatelessWidget {
  const _ServiceDetailDescription({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}

class _ServiceDetailFacts extends StatelessWidget {
  const _ServiceDetailFacts({required this.service});

  final Service service;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ServiceFact(
            icon: Icons.payments_outlined,
            label: 'Price',
            value: '\$${service.price}',
          ),
        ),
        Expanded(
          child: _ServiceFact(
            icon: Icons.schedule_outlined,
            label: 'Duration',
            value: '${service.durationMinutes} min',
          ),
        ),
      ],
    );
  }
}

class _ServiceFact extends StatelessWidget {
  const _ServiceFact({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, color: colorScheme.primary),
        const SizedBox(width: AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: textTheme.labelLarge),
            Text(value, style: textTheme.titleMedium),
          ],
        ),
      ],
    );
  }
}

class _ServiceDetailAction extends StatelessWidget {
  const _ServiceDetailAction({required this.service});

  final Service service;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => context.push(
        '/services/${service.id}/book',
        extra: service,
      ),
      icon: const Icon(Icons.calendar_month_outlined),
      label: Text('Book ${service.name}'),
    );
  }
}