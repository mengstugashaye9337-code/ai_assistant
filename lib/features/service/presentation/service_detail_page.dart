import 'package:flutter/material.dart';

import 'package:ai_assistant/features/service/domain/service.dart';

class ServiceDetailPage extends StatelessWidget {
  const ServiceDetailPage({required this.service, super.key});

  final Service service;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(service.name)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _ServiceDetailHeader(service: service),
          const SizedBox(height: 24),
          _ServiceDetailDescription(description: service.description),
          const SizedBox(height: 24),
          _ServiceDetailFacts(service: service),
          const SizedBox(height: 32),
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
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
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
      onPressed: () {},
      icon: const Icon(Icons.calendar_month_outlined),
      label: Text('Book ${service.name}'),
    );
  }
}