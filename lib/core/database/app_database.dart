import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AppDatabase extends GeneratedDatabase {
  AppDatabase() : super(_openConnection()) {
    _ready = _init();
  }

  AppDatabase.inMemory() : super(NativeDatabase.memory()) {
    _ready = _init();
  }

  late final Future<void> _ready;

  Future<void> _init() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS mood_entries (
        day TEXT PRIMARY KEY,
        mood TEXT NOT NULL
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS key_values (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS care_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ended_at TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL
      )
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS service_suggestions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        created_at TEXT NOT NULL,
        name TEXT NOT NULL,
        details TEXT NOT NULL
      )
    ''');
  }

  // ---- Moods ---------------------------------------------------------------

  Future<void> saveMood({required String day, required String mood}) async {
    await _ready;
    await customStatement(
      'INSERT OR REPLACE INTO mood_entries (day, mood) VALUES (?, ?)',
      [day, mood],
    );
  }

  Future<void> deleteMood(String day) async {
    await _ready;
    await customStatement('DELETE FROM mood_entries WHERE day = ?', [day]);
  }

  Future<List<Map<String, Object?>>> getMoodEntries() async {
    await _ready;
    final rows = await customSelect('SELECT day, mood FROM mood_entries ORDER BY day DESC').get();
    return rows.map((row) => row.data).toList(growable: false);
  }

  // ---- Simple key/value settings (profile, running session …) ------------

  Future<String?> readValue(String key) async {
    await _ready;
    final row = await customSelect(
      'SELECT value FROM key_values WHERE key = ?',
      variables: [Variable.withString(key)],
    ).getSingleOrNull();
    return row?.read<String>('value');
  }

  Future<void> writeValue(String key, String? value) async {
    await _ready;
    if (value == null) {
      await customStatement('DELETE FROM key_values WHERE key = ?', [key]);
    } else {
      await customStatement('INSERT OR REPLACE INTO key_values (key, value) VALUES (?, ?)', [key, value]);
    }
  }

  // ---- Care sessions -------------------------------------------------------

  Future<void> logCareSession({required DateTime endedAt, required Duration duration}) async {
    await _ready;
    await customStatement(
      'INSERT INTO care_sessions (ended_at, duration_seconds) VALUES (?, ?)',
      [endedAt.toIso8601String(), duration.inSeconds],
    );
  }

  // ---- Service suggestions -------------------------------------------------

  Future<void> saveServiceSuggestion({required String name, required String details}) async {
    await _ready;
    await customStatement(
      'INSERT INTO service_suggestions (created_at, name, details) VALUES (?, ?, ?)',
      [DateTime.now().toIso8601String(), name, details],
    );
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
