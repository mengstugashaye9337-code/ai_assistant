import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DataClassName('ServiceRow')
class Services extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  IntColumn get durationMinutes => integer()();
  RealColumn get price => real()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Services])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.connect() : this(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
  );
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ai_assistant.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
