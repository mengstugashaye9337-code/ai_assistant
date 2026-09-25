import 'dart:async';

import 'package:ai_assistant/features/service/domain/service.dart';
import 'package:ai_assistant/features/service/domain/services_repository.dart';
//import 'package:ai_assistant/features/service/infrastructure/repository/drift_services_repository.dart';

/// Coordinates immediate local reads with best-effort remote synchronization.
class LocalFirstServicesCoordinator implements ServicesRepository {
  final LocalServicesRepository _local;
  final ServicesRepository _remote;
   final Duration staleAfter;
  DateTime? _lastSuccessfulSync;
  Future<void>? _activeSync;

  LocalFirstServicesCoordinator({
    required LocalServicesRepository local,
    required ServicesRepository remote,
    this.staleAfter = const Duration(minutes: 15),
  }) : _local = local,
       _remote = remote;

 

  @override
  Future<List<Service>> getServices() async {
    final cached = await _local.getServices();

    if (cached.isEmpty) {
      await sync();
      return _local.getServices();
    }

    if (_isStale) {
      unawaited(_syncInBackground());
    }

    return cached;
  }

  @override
  Future<Service?> getServiceById(String id) async {
    final cached = await _local.getServiceById(id);
    if (cached != null) return cached;

    final remoteService = await _remote.getServiceById(id);
    if (remoteService != null) {
      final remoteServices = await _remote.getServices();
      await _replaceLocal(remoteServices);
      _lastSuccessfulSync = DateTime.now();
    }
    return remoteService;
  }

  Future<void> sync() {
    final activeSync = _activeSync;
    if (activeSync != null) return activeSync;

    final nextSync = _syncFromRemote();
    _activeSync = nextSync;
    return nextSync.whenComplete(() => _activeSync = null);
  }

  bool get _isStale =>
      _lastSuccessfulSync == null ||
      DateTime.now().difference(_lastSuccessfulSync!) >= staleAfter;

  Future<void> _syncFromRemote() async {
    final services = await _remote.getServices();
    await _replaceLocal(services);
    _lastSuccessfulSync = DateTime.now();
  }

  Future<void> _syncInBackground() async {
    try {
      await sync();
    } catch (_) {}
  }

  Future<void> _replaceLocal(List<Service> services) =>
      _local.replaceServices(services);
}
