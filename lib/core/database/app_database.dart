import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AppDatabase extends GeneratedDatabase {
  AppDatabase() : super(_openConnection()) {
    _init();
  }

  AppDatabase.inMemory() : super(NativeDatabase.memory()) {
    _init();
  }

  Future<void> _init() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS mood_entries (
        day TEXT PRIMARY KEY,
        mood TEXT NOT NULL
      )
    ''');
  }

  Future<void> saveMood({required String day, required String mood}) {
    return customStatement(
      'INSERT OR REPLACE INTO mood_entries (day, mood) VALUES (?, ?)',
      [day, mood],
    );
  }

  Future<List<Map<String, Object?>>> getMoodEntries() async {
    final rows = await customSelect('SELECT day, mood FROM mood_entries ORDER BY day DESC').get();
    return rows.map((row) => row.data).toList(growable: false);
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'carepals.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
