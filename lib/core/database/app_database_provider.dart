import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_assistant/core/database/app_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_database_provider.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  return AppDatabase.connect();
}
