import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import '../models/surah.dart';
import '../models/ayah.dart';
import '../models/reading_mode.dart';
import '../models/translation_edition.dart';

import 'wbw_database_service.dart';

/// Quran Service — AlQuran.cloud + Quran.com dono APIs use karta hai
/// AlQuran.cloud  → Surah list, Ayah text, Translation
/// Quran.com v4   → Word-by-word, Tajweed segments, Audio
class QuranService {
  final Dio _dio;
  final Box<dynamic> _cacheBox;
  final WbwDatabaseService _wbwDbService;

  static const String _alQuranBase = 'https://api.alquran.cloud/v1';
  static const String _quranComBase = 'https://api.quran.com/api/v4';

  // Quran.com audio reciters
  static const int _defaultReciterId = 7; // Mishari Rashid Al-Afasy

  // ─── In-Memory Caches (performance) ─────────
  List<Surah>? _surahsMemoryCache;
  final Map<String, Surah> _surahDetailCache = {};
  static const int _maxCachedSurahs = 5;

  QuranService(this._dio, this._cacheBox, this._wbwDbService);

  // ─────────────────────────────────────────────
  // 1. SURAH LIST  (AlQuran.cloud)
  // ─────────────────────────────────────────────

  Future<List<TranslationEdition>> getAvailableTranslations() async {
    const cacheKey = 'available_translations';
    try {
      final cached = _cacheBox.get(cacheKey);
      if (cached != null) {
        return (cached as List)
            .map((e) => TranslationEdition.fromJson(Map<String, dynamic>.from(e as Map)))
            .where((e) => !_isBuck(e)) // Filter out buck editions
            .toList();
      }

      final res = await _dio.get('$_alQuranBase/edition/type/translation');
      if (res.statusCode == 200) {
        final data = res.data['data'] as List;
        final editions = data
            .map((e) => TranslationEdition.fromJson(Map<String, dynamic>.from(e as Map)))
            .where((e) => e.format == 'text') // Exclude audio-only editions
            .where((e) => !_isBuck(e)) // Filter out buck editions
            .toList();
        await _cacheBox.put(cacheKey, data);
        return editions;
      }
      return [];
    } catch (_) {
      final cached = _cacheBox.get(cacheKey);
      if (cached != null) {
        return (cached as List)
            .map((e) => TranslationEdition.fromJson(Map<String, dynamic>.from(e as Map)))
            .where((e) => !_isBuck(e)) // Filter out buck editions
            .toList();
      }
      return [];
    }
  }

  Future<List<Surah>> getAllSurahs() async {
    // Memory cache — instant return (no deserialization)
    if (_surahsMemoryCache != null) return _surahsMemoryCache!;

    const cacheKey = 'all_surahs';
    try {
      final cached = _cacheBox.get(cacheKey);
      if (cached != null) {
        final surahs = (cached as List)
            .map((e) => Surah.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        _surahsMemoryCache = surahs;
        return surahs;
      }

      final res = await _dio.get('$_alQuranBase/surah');
      if (res.statusCode == 200) {
        final data = res.data['data'] as List;
        final surahs = data.map((e) => Surah.fromJson(Map<String, dynamic>.from(e as Map))).toList();
        await _cacheBox.put(cacheKey, data);
        _surahsMemoryCache = surahs;
        return surahs;
      }
      throw Exception('Surah list load nahi hua');
    } on DioException catch (e) {
      final cached = _cacheBox.get(cacheKey);
      if (cached != null) {
        final surahs = (cached as List)
            .map((e) => Surah.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        _surahsMemoryCache = surahs;
        return surahs;
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Returns cached surah instantly if available, null otherwise (no API call)
  Surah? getCachedSurah(int surahNumber, String translationEdition) {
    // Memory cache first
    final memKey = 'surah_${surahNumber}_$translationEdition';
    if (_surahDetailCache.containsKey(memKey)) {
      return _surahDetailCache[memKey];
    }
    // Hive cache
    final cacheKey = 'surah_v2_${surahNumber}_${translationEdition}_ur_maududi';
    final cached = _cacheBox.get(cacheKey);
    if (cached != null) {
      final surah = Surah.fromJson(Map<String, dynamic>.from(cached as Map));
      cacheDetailSurah(memKey, surah);
      return surah;
    }
    return null;
  }

  /// Add surah to in-memory LRU cache (keeps last 10). Public so Bloc can also update it.
  void cacheDetailSurah(String key, Surah surah) {
    if (_surahDetailCache.length >= _maxCachedSurahs) {
      _surahDetailCache.remove(_surahDetailCache.keys.first);
    }
    _surahDetailCache[key] = surah;
  }

  // ─────────────────────────────────────────────
  // 2. SURAH WITH TRANSLATION  (AlQuran.cloud)
  // ─────────────────────────────────────────────

  Future<Surah> getSurahWithTranslation(
      int surahNumber,
      String translationEdition,
      ) async {
    final cacheKey = 'surah_v2_${surahNumber}_${translationEdition}_ur_maududi';
    try {
      final cached = _cacheBox.get(cacheKey);
      if (cached != null) {
        return Surah.fromJson(Map<String, dynamic>.from(cached as Map));
      }

      // Arabic (Uthmani) + Tajweed + Translation + Tafseer (ur.maududi)
      // AlQuran.cloud allows multiple editions comma separated
      final editions = 'quran-uthmani,quran-tajweed,$translationEdition,ur.maududi';
      final res = await _dio.get('$_alQuranBase/surah/$surahNumber/editions/$editions');

      if (res.statusCode == 200) {
        final data = res.data['data'] as List;
        
        // Data order depends on response, usually matches request order but better to check identifiers if possible.
        // Usually: [0]=Uthmani, [1]=Tajweed, [2]=Translation, [3]=Tafseer
        
        final arabicData = Map<String, dynamic>.from(data[0] as Map);
        final tajweedData = Map<String, dynamic>.from(data[1] as Map);
        final translData = Map<String, dynamic>.from(data[2] as Map);
        final tafseerData = Map<String, dynamic>.from(data[3] as Map); // New Tafseer data

        final surah = Surah.fromJson(arabicData);
        final tajweedAyahs = tajweedData['ayahs'] as List;
        final translAyahs = translData['ayahs'] as List;
        final tafseerAyahs = tafseerData['ayahs'] as List;

        final mergedAyahs = <Ayah>[];
        for (int i = 0; i < surah.ayahs!.length; i++) {
          final ar = surah.ayahs![i];
          final tr = Map<String, dynamic>.from(translAyahs[i] as Map);
          final tj = Map<String, dynamic>.from(tajweedAyahs[i] as Map);
          final tf = Map<String, dynamic>.from(tafseerAyahs[i] as Map); // Tafseer ayah
          
          final rawTrans = tr['text'] as String?;
          final cleanTrans = rawTrans?.replaceAll(RegExp(r'<[^>]*>'), '').trim();

          mergedAyahs.add(ar.copyWith(
            translation: cleanTrans,
            tajweedText: tj['text'] as String?,
            tafseerText: tf['text'] as String?, // Store Tafseer text
          ));
        }

        final finalSurah = surah.copyWith(ayahs: mergedAyahs);
        await _cacheBox.put(cacheKey, finalSurah.toJson());
        return finalSurah;
      }
      throw Exception('Surah load nahi hua');
    } on DioException catch (e) {
      final cached = _cacheBox.get(cacheKey);
      if (cached != null) {
        return Surah.fromJson(Map<String, dynamic>.from(cached as Map));
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  // ─────────────────────────────────────────────
  // 2b. SURAH STREAMING  (Progressive pipe)
  // ─────────────────────────────────────────────

  /// Surah header immediately, then streams partial ayah lists as they parse.
  /// Yields: first an empty Surah (meta only), then progressively filled Surahs.
  Stream<Surah> getSurahStream(
    int surahNumber,
    String translationEdition,
  ) async* {
    final cacheKey = 'surah_v2_${surahNumber}_${translationEdition}_ur_maududi';

    // Check Hive cache first — instant yield, no spinner
    final cached = _cacheBox.get(cacheKey);
    if (cached != null) {
      yield Surah.fromJson(Map<String, dynamic>.from(cached as Map));
      return;
    }

    // Memory cache check
    final memKey = 'surah_${surahNumber}_$translationEdition';
    if (_surahDetailCache.containsKey(memKey)) {
      yield _surahDetailCache[memKey]!;
      return;
    }

    try {
      final editions = 'quran-uthmani,quran-tajweed,$translationEdition,ur.maududi';
      final res = await _dio.get('$_alQuranBase/surah/$surahNumber/editions/$editions');

      if (res.statusCode != 200) throw Exception('Surah load nahi hua');

      final data = res.data['data'] as List;
      final arabicData = Map<String, dynamic>.from(data[0] as Map);
      final tajweedData = Map<String, dynamic>.from(data[1] as Map);
      final translData  = Map<String, dynamic>.from(data[2] as Map);
      final tafseerData = Map<String, dynamic>.from(data[3] as Map);

      final baseSurah   = Surah.fromJson(arabicData);
      final tajweedAyahs = tajweedData['ayahs'] as List;
      final translAyahs  = translData['ayahs'] as List;
      final tafseerAyahs = tafseerData['ayahs'] as List;

      // Yield meta-only (empty ayahs) immediately so reader builds header + skeletons
      yield baseSurah.copyWith(ayahs: []);

      // Parse and yield ayahs in batches of 10
      const batchSize = 10;
      final accumulated = <Ayah>[];

      for (int i = 0; i < baseSurah.ayahs!.length; i++) {
        final ar = baseSurah.ayahs![i];
        final tr = Map<String, dynamic>.from(translAyahs[i] as Map);
        final tj = Map<String, dynamic>.from(tajweedAyahs[i] as Map);
        final tf = Map<String, dynamic>.from(tafseerAyahs[i] as Map);
        final rawTrans = tr['text'] as String?;
        final cleanTrans = rawTrans?.replaceAll(RegExp(r'<[^>]*>'), '').trim();

        accumulated.add(ar.copyWith(
          translation: cleanTrans,
          tajweedText: tj['text'] as String?,
          tafseerText: tf['text'] as String?,
        ));

        // Yield first batch of 5 immediately, then every 10
        final yieldAt = i == 4 || ((i + 1) % batchSize == 0) || (i == baseSurah.ayahs!.length - 1);
        if (yieldAt) {
          yield baseSurah.copyWith(ayahs: List.unmodifiable(accumulated));
        }
      }

      // Cache the final result
      final finalSurah = baseSurah.copyWith(ayahs: accumulated);
      await _cacheBox.put(cacheKey, finalSurah.toJson());
      cacheDetailSurah(memKey, finalSurah);
    } on DioException catch (e) {
      // Return cached on network failure
      final cached = _cacheBox.get(cacheKey);
      if (cached != null) {
        yield Surah.fromJson(Map<String, dynamic>.from(cached as Map));
        return;
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  // ─────────────────────────────────────────────
  // 3. WORD-BY-WORD + TAJWEED  (Quran.com v4)
  // ─────────────────────────────────────────────

  /// Quran.com se ek surah ke sare verses + words lao
  /// Har word mein arabic, transliteration, translation, tajweed segments hain
  Future<List<Ayah>> getSurahWithWordByWord(
      int surahNumber, {
        String languageCode = 'ur',
      }) async {
    final cacheKey = 'surah_wbw_v6_${surahNumber}_${languageCode}_audio';
    try {
      final cached = _cacheBox.get(cacheKey);
      if (cached != null) {
        return (cached as List)
            .map((e) => Ayah.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }

      final ayahs = <Ayah>[];
      int page = 1;
      bool hasMore = true;

      while (hasMore) {
        final res = await _dio.get(
          '$_quranComBase/verses/by_chapter/$surahNumber',
          queryParameters: {
            'words': true,
            'word_fields': 'text_uthmani,transliteration,tajweed,audio',
            'word_translation_language': languageCode == 'ur' ? 'ur' : 'en',
            'per_page': 300, // Fetch up to 300 verses (Baqarah has 286)
            'page': page,
          },
        );

        if (res.statusCode == 200) {
          final verses = res.data['verses'] as List;
          
          // Quran.com v4 pagination can be in top-level 'pagination' or 'meta'
          final dynamic paginationData = res.data['pagination'] ?? res.data['meta']?['pagination'];
          final int totalPages = paginationData?['total_pages'] as int? 
              ?? res.data['meta']?['total_pages'] as int? 
              ?? 1;

          for (final v in verses) {
            final ayah = Ayah.fromQuranComJson(Map<String, dynamic>.from(v as Map));
            ayahs.add(ayah);
          }

          hasMore = page < totalPages;
          page++;
        } else {
          break;
        }
      }

      // Fetch local translations
      final localTranslations = await _wbwDbService.getSurahTranslations(surahNumber, languageCode);

      debugPrint('QuranService: WBW merge → ${ayahs.length} ayahs, ${localTranslations.length} DB entries');
      
      // Log first few keys from both sides for debugging
      if (localTranslations.isNotEmpty) {
        final dbKeys = localTranslations.keys.take(5).toList();
        debugPrint('QuranService: DB keys sample: $dbKeys');
      }
      if (ayahs.isNotEmpty && ayahs.first.ayahWords != null) {
        final apiKeys = ayahs.first.ayahWords!
            .take(5)
            .map((w) => '${ayahs.first.numberInSurah}:${w.position}')
            .toList();
        debugPrint('QuranService: API keys sample: $apiKeys');
      }

      // Merge translations into words
      for (int i = 0; i < ayahs.length; i++) {
        final ayah = ayahs[i];
        if (ayah.ayahWords != null) {
          final updatedWords = ayah.ayahWords!.map((word) {
            final key = '${ayah.numberInSurah}:${word.position}';
            final localTrans = localTranslations[key];

            // Use local DB first, then API translation as fallback
            final finalTranslation = localTrans 
                ?? word.translation  // API translation (already parsed)
                ?? '';

            return AyahWord(
              position: word.position,
              arabic: word.arabic,
              translation: finalTranslation,
              transliteration: word.transliteration,
              tajweedSegments: word.tajweedSegments,
              audioUrl: word.audioUrl,  // Preserve audio URL from API
            );
          }).toList();
          ayahs[i] = ayah.copyWith(words: updatedWords);
        }
      }

      // Cache karo
      await _cacheBox.put(cacheKey, ayahs.map((a) => a.toJson()).toList());
      return ayahs;
    } on DioException catch (e) {
      final cached = _cacheBox.get(cacheKey);
      if (cached != null) {
        return (cached as List)
            .map((e) => Ayah.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
      throw Exception('Word-by-word load nahi hua: ${e.message}');
    }
  }

  // ─────────────────────────────────────────────
  // 4. AUDIO  (Quran.com v4)
  // ─────────────────────────────────────────────

  /// Single ayah ki audio URL
  Future<String?> getAyahAudioUrl(
      int surahNumber,
      int ayahNumber, {
        int reciterId = _defaultReciterId,
      }) async {
    final verseKey = '$surahNumber:$ayahNumber';
    final cacheKey = 'audio_${verseKey}_$reciterId';

    try {
      final cached = _cacheBox.get(cacheKey);
      if (cached != null) return cached as String;

      final res = await _dio.get(
        '$_quranComBase/recitations/$reciterId/by_ayah/$verseKey',
      );

      if (res.statusCode == 200) {
        final audioFiles = res.data['audio_files'] as List?;
        if (audioFiles != null && audioFiles.isNotEmpty) {
          final url = 'https://verses.quran.com/${audioFiles[0]['url']}';
          await _cacheBox.put(cacheKey, url);
          return url;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Reciters list
  Future<List<Map<String, dynamic>>> getReciters() async {
    const cacheKey = 'reciters_list';
    try {
      final cached = _cacheBox.get(cacheKey);
      if (cached != null) {
        return (cached as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }

      final res = await _dio.get('$_quranComBase/resources/recitations');
      if (res.statusCode == 200) {
        final data = res.data['recitations'] as List;
        final reciters = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        await _cacheBox.put(cacheKey, data);
        return reciters;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // 5. SEARCH  (AlQuran.cloud)
  // ─────────────────────────────────────────────

  Future<List<Ayah>> searchQuran(String query, String edition) async {
    try {
      // Try with selected edition first
      final res = await _dio.get(
        '$_alQuranBase/search/$query/$edition',
      );
      if (res.statusCode == 200) {
        final matches = res.data['data']['matches'] as List;
        return matches.map((e) => Ayah.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      }
      return [];
    } on DioException catch (e) {
      // If 404/400, try fallback to en.sahih (standard search)
      if (e.response?.statusCode == 404 || e.response?.statusCode == 400) {
        if (edition != 'en.sahih') {
          return searchQuran(query, 'en.sahih');
        }
      }
      throw Exception('Search error: ${e.message}');
    } catch (e) {
      throw Exception('Search error: $e');
    }
  }

  // ─────────────────────────────────────────────
  // 6. BOOKMARKS  (Local — Hive)
  // ─────────────────────────────────────────────

  Future<void> bookmarkAyah(int surahNumber, int ayahNumber) async {
    final bookmarks = _cacheBox.get('bookmarks', defaultValue: <dynamic>[]) as List;
    final key = '$surahNumber:$ayahNumber';
    if (!bookmarks.contains(key)) {
      bookmarks.add(key);
      await _cacheBox.put('bookmarks', bookmarks);
    }
  }

  Future<void> removeBookmark(int surahNumber, int ayahNumber) async {
    final bookmarks = _cacheBox.get('bookmarks', defaultValue: <dynamic>[]) as List;
    bookmarks.remove('$surahNumber:$ayahNumber');
    await _cacheBox.put('bookmarks', bookmarks);
  }

  Future<List<String>> getBookmarks() async {
    final bookmarks = _cacheBox.get('bookmarks', defaultValue: <dynamic>[]) as List;
    return bookmarks.cast<String>();
  }

  Future<bool> isBookmarked(int surahNumber, int ayahNumber) async {
    final bookmarks = await getBookmarks();
    return bookmarks.contains('$surahNumber:$ayahNumber');
  }

  // ─────────────────────────────────────────────
  // 7. LAST READ  (Local — Hive)
  // ─────────────────────────────────────────────

  Future<void> saveLastRead(int surahNumber, int ayahNumber) async {
    // 1. Global last read (for Home/Banner)
    await _cacheBox.put('last_read', {
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // 2. Per-Surah progress (for List Tiles)
    final Map<int, int> progressMap = Map<int, int>.from(
        _cacheBox.get('surah_progress', defaultValue: <int, int>{}) as Map);
    progressMap[surahNumber] = ayahNumber;
    await _cacheBox.put('surah_progress', progressMap);
  }

  Future<void> saveLastListenedVbv(int surahNumber, int ayahNumber) async {
    await _cacheBox.put('last_listened_vbv', {
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'timestamp': DateTime.now().toIso8601String(),
    });

    // Sync with surah_progress for list UI
    final Map<int, int> progressMap = Map<int, int>.from(
        _cacheBox.get('surah_progress', defaultValue: <int, int>{}) as Map);
    progressMap[surahNumber] = ayahNumber;
    await _cacheBox.put('surah_progress', progressMap);
  }

  Future<Map<String, dynamic>?> getLastListenedVbv() async {
    final data = _cacheBox.get('last_listened_vbv');
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>?> getLastRead() async {
    final data = _cacheBox.get('last_read');
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<int, int>> getAllSurahProgress() async {
    final data = _cacheBox.get('surah_progress');
    if (data == null) return {};
    return Map<int, int>.from(data as Map);
  }

  // ─────────────────────────────────────────────
  // 8. READING PREFERENCES  (Local — Hive)
  // ─────────────────────────────────────────────

  Future<void> saveReadingPreferences(ReadingPreferences prefs) async {
    await _cacheBox.put('reading_prefs', {
      'displayMode': prefs.displayMode.index,
      'showTajweed': prefs.showTajweed,
      'arabicFontSize': prefs.arabicFontSize,
      'translationFontSize': prefs.translationFontSize,
      'selectedTranslation': prefs.selectedTranslation,
      'showTransliteration': prefs.showTransliteration,
      'wbwLanguage': prefs.wbwLanguage,
    });
  }

  Future<ReadingPreferences> getReadingPreferences() async {
    final data = _cacheBox.get('reading_prefs');
    if (data == null) return const ReadingPreferences();
    final map = Map<String, dynamic>.from(data as Map);
    return ReadingPreferences(
      displayMode: ReadingDisplayMode.values[map['displayMode'] as int? ?? 1],
      showTajweed: map['showTajweed'] as bool? ?? true,
      arabicFontSize: (map['arabicFontSize'] as num?)?.toDouble() ?? 28.0,
      translationFontSize: (map['translationFontSize'] as num?)?.toDouble() ?? 16.0,
      selectedTranslation: map['selectedTranslation'] as String? ?? 'ur.jalandhry',
      showTransliteration: map['showTransliteration'] as bool? ?? false,
      wbwLanguage: map['wbwLanguage'] as String? ?? 'ur',
    );
  }

  bool _isBuck(TranslationEdition edition) {
    final searchStr =
        ('${edition.identifier} ${edition.name} ${edition.englishName}').toLowerCase();
    return searchStr.contains('buck');
  }
}