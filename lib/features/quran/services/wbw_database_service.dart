import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Represents a single word's translation
class WbwWord {
  final int surahNumber;
  final int ayahNumber;
  final int wordNumber;
  final String text;

  const WbwWord({
    required this.surahNumber,
    required this.ayahNumber,
    required this.wordNumber,
    required this.text,
  });

  /// Key format: "ayah:word" — useful for quick lookups
  String get key => '$ayahNumber:$wordNumber';

  @override
  String toString() =>
      'WbwWord($surahNumber:$ayahNumber:$wordNumber => "$text")';
}

class WbwDatabaseService {
  // Singleton
  WbwDatabaseService._();
  static final WbwDatabaseService instance = WbwDatabaseService._();

  // Cache of open DB instances per language
  final Map<String, Database> _openDbs = {};
  // Cache of table names per language
  final Map<String, String> _tableNames = {};

  /// Maps language code -> SQLite asset file name.
  /// All files should be placed in: lib/assets/data/quran/wbw_translations/
  static const Map<String, String> languageDbMap = {
    'ur':  'urdu-wbw.db',
    'en':  'colored-english-wbw-translation.db',
    'fr':  'french-wbw-translation.db',
    'hi':  'hindi-wbw-translation.db',
    'bn':  'bangali-word-by-word-translation.db',
    'id':  'indonesian-word-by-word-translation.db',
    'inh': 'ingush-wbw-translation.db',
    'fa':  'persian-wbw-translation.db',
    'ta':  'tamil-wbw-translation.db',
    'tr':  'turkish-wbw-translation.db',
  };

  static const String _assetBasePath =
      'lib/assets/data/quran/wbw_translations';

  // ─────────────────────────────────────────────
  // Public API
  // ─────────────────────────────────────────────

  /// Opens (and caches) the DB for [languageCode].
  /// Copies it from assets to the device's documents directory on first run.
  Future<Database?> getDb(String languageCode) async {
    // Return early on Web as raw sqflite DB files cannot be copied to IndexedDB natively via dart:io
    if (kIsWeb) {
      debugPrint('WbwDatabaseService: ⚠️ SQLite is not supported on Flutter Web without sqflite_common_ffi_web.');
      return null;
    }

    if (_openDbs.containsKey(languageCode)) return _openDbs[languageCode];

    final fileName = languageDbMap[languageCode];
    if (fileName == null) {
      debugPrint('WbwDatabaseService: No DB mapped for "$languageCode"');
      return null;
    }

    try {
      final db = await _openFromAssets(fileName);
      _openDbs[languageCode] = db;

      // Detect and cache table name
      final tableName = await _detectTableName(db);
      _tableNames[languageCode] = tableName;

      // Log row count for verification
      final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $tableName'));
      debugPrint('WbwDatabaseService: ✅ Opened "$languageCode" DB → table=$tableName, rows=$count');

      // Log sample data for first opened DB
      if (_openDbs.length == 1) {
        final sample = await db.query(tableName,
            where: 'surah_number = ? AND ayah_number = ?',
            whereArgs: [1, 1],
            orderBy: 'CAST(word_number AS INTEGER)',
            limit: 5);
        for (final row in sample) {
          debugPrint('WbwDatabaseService: SAMPLE ROW: $row');
        }
      }

      return db;
    } catch (e, stack) {
      debugPrint(
          'WbwDatabaseService: ❌ Failed to open "$languageCode" DB: $e\n$stack');
      return null;
    }
  }

  Future<List<WbwWord>> getAyahWords(
    int surahNumber,
    int ayahNumber,
    String languageCode,
  ) async {
    final db = await getDb(languageCode);
    if (db == null) return [];

    final tableName = _tableNames[languageCode] ?? 'word_translation';
    final rows = await db.query(
      tableName,
      where: 'surah_number = ? AND ayah_number = ?',
      whereArgs: [surahNumber, ayahNumber],
      orderBy: 'CAST(word_number AS INTEGER)',
    );

    return rows.map(_rowToWord).toList();
  }

  Future<Map<int, List<WbwWord>>> getSurahWords(
    int surahNumber,
    String languageCode,
  ) async {
    final db = await getDb(languageCode);
    if (db == null) {
      debugPrint('WbwDatabaseService: ❌ getSurahWords - db is null for $languageCode');
      return {};
    }

    final tableName = _tableNames[languageCode] ?? 'word_translation';
    final rows = await db.query(
      tableName,
      where: 'surah_number = ?',
      whereArgs: [surahNumber],
      orderBy: 'ayah_number, CAST(word_number AS INTEGER)',
    );

    debugPrint('WbwDatabaseService: getSurahWords(surah=$surahNumber, lang=$languageCode) → ${rows.length} rows');

    final Map<int, List<WbwWord>> result = {};
    for (final row in rows) {
      final word = _rowToWord(row);
      result.putIfAbsent(word.ayahNumber, () => []).add(word);
    }
    return result;
  }

  /// Returns a flat Map keyed by "ayah:word"
  /// (same shape your old JSON service returned).
  Future<Map<String, String>> getSurahTranslations(
    int surahNumber,
    String languageCode,
  ) async {
    debugPrint('WbwDatabaseService: getSurahTranslations(surah: $surahNumber, lang: $languageCode)');
    final wordsMap = await getSurahWords(surahNumber, languageCode);
    
    final Map<String, String> flat = {};
    for (final words in wordsMap.values) {
      for (final w in words) {
        flat[w.key] = w.text;
      }
    }
    
    debugPrint('WbwDatabaseService: Returning ${flat.length} entries for surah $surahNumber');
    return flat;
  }

  /// Close all open databases (call on app dispose if needed).
  Future<void> closeAll() async {
    for (final db in _openDbs.values) {
      await db.close();
    }
    _openDbs.clear();
    _tableNames.clear();
  }

  // ─────────────────────────────────────────────
  // Internal helpers
  // ─────────────────────────────────────────────

  /// Copies the SQLite file from assets to the system's database directory
  /// if it doesn't already exist or if we want to force a refresh.
  Future<Database> _openFromAssets(String fileName) async {
    try {
      // Use getDatabasesPath() which works across platforms
      // and is safer for web/js environments than path_provider
      final String dbDir = await getDatabasesPath();
      final String dbPath = join(dbDir, 'wbw_databases', fileName);
      final dbFile = File(dbPath);

      // Always ensure parent directory exists
      await dbFile.parent.create(recursive: true);

      // Copy from assets if file doesn't exist
      if (!await dbFile.exists()) {
        debugPrint('WbwDatabaseService: Copying DB $fileName to $dbPath');
        final byteData = await rootBundle.load('$_assetBasePath/$fileName');
        final bytes = byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        );
        await dbFile.writeAsBytes(bytes, flush: true);
        debugPrint('WbwDatabaseService: DB $fileName copied successfully, ${bytes.length} bytes');
      } else {
        debugPrint('WbwDatabaseService: DB $fileName already exists at $dbPath');
      }

      // Open the database using the full path
      final db = await openDatabase(dbPath, readOnly: true);
      
      // Sanity check: verify table structure
      final tableCheck = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('word_translation', 'words')");
      
      if (tableCheck.isEmpty) {
        debugPrint('WbwDatabaseService: WARNING - DB $fileName has NO expected tables!');
      } else {
        debugPrint('WbwDatabaseService: DB $fileName opened. Tables: ${tableCheck.map((t) => t['name']).toList()}');
      }

      return db;
    } catch (e, stack) {
      debugPrint('WbwDatabaseService: Error in _openFromAssets for $fileName: $e\n$stack');
      rethrow;
    }
  }

  /// Detects the actual table name in the database
  Future<String> _detectTableName(Database db) async {
    final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('word_translation', 'words')");
    if (result.any((row) => row['name'] == 'word_translation')) {
      return 'word_translation';
    }
    if (result.any((row) => row['name'] == 'words')) {
      return 'words';
    }
    // List all tables for debugging
    final allTables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'");
    debugPrint('WbwDatabaseService: ⚠️ No expected tables! Found: ${allTables.map((t) => t['name']).toList()}');
    return 'word_translation'; // Default
  }

  WbwWord _rowToWord(Map<String, dynamic> row) {
    // Try both naming conventions if needed
    final sNo = row['surah_id'] ?? row['surah_number'] ?? 0;
    final aNo = row['ayah_id']  ?? row['ayah_number']  ?? 0;
    final wNo = row['word_id']  ?? row['word_number']  ?? 0;
    
    final txtRaw = (row['translation'] ?? row['text'] ?? '').toString();
    // Remove any HTML tags like <span class="..."> so it displays cleanly in the UI
    final txt = txtRaw.replaceAll(RegExp(r'<[^>]*>'), '').trim();

    return WbwWord(
      surahNumber: int.tryParse(sNo.toString()) ?? 0,
      ayahNumber:  int.tryParse(aNo.toString()) ?? 0,
      wordNumber:  int.tryParse(wNo.toString()) ?? 0,
      text:        txt,
    );
  }
}
