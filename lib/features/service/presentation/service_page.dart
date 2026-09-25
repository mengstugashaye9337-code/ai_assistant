import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    if (services.isEmpty) {
      return const Center(child: Text('No services available.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final service = services[index];
        return Card(
          child: ListTile(
            onTap: () => context.push('/services/${service.id}', extra: service),
            title: Text(service.name),
            subtitle: Text(service.description),
            trailing: Text('\$${service.price}'),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Could not load services.'),
            const SizedBox(height: 8),
            Text('$error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
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
