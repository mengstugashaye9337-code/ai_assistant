import 'package:ai_assistant/features/service/domain/services_repository.dart';
import 'package:ai_assistant/features/service/infrastructure/repository/drift_services_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ai_assistant/core/database/app_database_provider.dart';
//part 'drift_services_provider.g.dart';



final driftServicesRepositoryProvider = Provider<LocalServicesRepository>((ref) {
  return DriftServicesRepository(database: ref.read(appDatabaseProvider));
});