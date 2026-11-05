import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ai_assistant/core/theme/app_spacing.dart';
import 'package:ai_assistant/features/service/application/service_notifier.dart';
import 'package:ai_assistant/features/service/application/service_state.dart';
import 'package:ai_assistant/features/service/domain/service.dart';

class ServicePage extends ConsumerStatefulWidget {
  const ServicePage({super.key});

  @override
  ConsumerState<ServicePage> createState() => _ServicePageState();
}
 
class _ServicePageState extends ConsumerState<ServicePage> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(serviceNotifierProvider.notifier).loadServices(),
    );
  }
  @override
  Widget build(BuildContext context) {
    final serviceState = ref.watch(serviceNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: switch (serviceState.status) {
        ServiceIdle() ||
        ServiceLoading() => const Center(child: CircularProgressIndicator()),
        ServiceLoaded() => _ServiceList(services: serviceState.services),
        ServiceError(:final error) => _ServiceError(
          error: error,
          onRetry: () =>
              ref.read(serviceNotifierProvider.notifier).loadServices(),
        ),
      },
    );
  }
}

class _ServiceList extends StatelessWidget {
  const _ServiceList({required this.services});

  final List<Service> services;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (services.isEmpty) {
      return Center(
        child: Text(
          'No services available.',
          style: textTheme.bodyLarge,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: services.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final service = services[index];
        return Card(
          child: ListTile(
            onTap: () => context.push('/services/${service.id}', extra: service),
            title: Text(service.name, style: textTheme.titleMedium),
            subtitle: Text(service.description, style: textTheme.bodyMedium),
            trailing: Text('\$${service.price}', style: textTheme.labelLarge),
          ),
        );
      },
    );
  }
}

class _ServiceError extends StatelessWidget {
  const _ServiceError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Could not load services.', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '$error',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
            ),
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
