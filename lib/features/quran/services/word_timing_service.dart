import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

/// Word-level timing data from Quran.com QDC API.
/// Each segment: [wordIndex, startMs, endMs]
class WordTiming {
  final int wordIndex; // 1-based
  final int startMs;
  final int endMs;

  const WordTiming({
    required this.wordIndex,
    required this.startMs,
    required this.endMs,
  });
}

class VerseTiming {
  final String verseKey; // e.g. "1:1"
  final int timestampFrom;
  final int timestampTo;
  final int duration;
  final List<WordTiming> wordTimings;

  const VerseTiming({
    required this.verseKey,
    required this.timestampFrom,
    required this.timestampTo,
    required this.duration,
    required this.wordTimings,
  });

  int get surahNumber => int.parse(verseKey.split(':')[0]);
  int get ayahNumber => int.parse(verseKey.split(':')[1]);
}

class ChapterAudioData {
  final String audioUrl;
  final int durationMs;
  final List<VerseTiming> verseTimings;

  const ChapterAudioData({
    required this.audioUrl,
    required this.durationMs,
    required this.verseTimings,
  });
}

/// Fetches chapter-level audio with word-level timing segments
/// from Quran.com QDC API.
class WordTimingService {
  final Dio _dio;
  final Box<dynamic> _cacheBox;

  // Quran.com QDC reciter IDs (different from v4 reciter IDs)
  // 7 = Mishari Rashid Al-Afasy
  static const Map<String, int> reciterToQdcId = {
    'alafasy': 7,
    'abdulbasit_mujawwad': 1,
    'abdulbasit_murattal': 2,
    'sudais': 6,
    'shuraim': 11,
    'hanirifai': 18,
    'mahermuaiqly': 5,
    'husary': 3,
    'husary_mujawwad': 4,
    'hudhaify': 8,
    'muhammadayyoub': 9,
    'ahmedajamy': 14,
    'shaatree': 10,
    'muhammadjibreel': 16,
    'minshawi_mujawwad': 12,
    'minshawi_murattal': 13,
  };

  WordTimingService(this._dio, this._cacheBox);

  /// Fetch chapter audio URL + per-word timing segments.
  /// Uses the QDC API: /api/qdc/audio/reciters/{id}/audio_files?chapter={n}&segments=true
  Future<ChapterAudioData?> getChapterAudioWithSegments(
    int chapterNumber, {
    String reciterId = 'alafasy',
  }) async {
    final qdcId = reciterToQdcId[reciterId] ?? 7;
    final cacheKey = 'chapter_segments_v1_${chapterNumber}_$qdcId';

    try {
      // Check cache
      final cached = _cacheBox.get(cacheKey);
      if (cached != null) {
        return _parseFromCache(cached);
      }

      final res = await _dio.get(
        'https://api.qurancdn.com/api/qdc/audio/reciters/$qdcId/audio_files',
        queryParameters: {
          'chapter': chapterNumber,
          'segments': true,
        },
      );

      if (res.statusCode == 200) {
        final audioFiles = res.data['audio_files'] as List?;
        if (audioFiles == null || audioFiles.isEmpty) return null;

        final file = audioFiles[0] as Map<String, dynamic>;
        final audioUrl = file['audio_url'] as String;
        final durationMs = file['duration'] as int? ?? 0;
        final verseTimingsRaw = file['verse_timings'] as List? ?? [];

        final verseTimings = <VerseTiming>[];
        for (final vt in verseTimingsRaw) {
          final vtMap = vt as Map<String, dynamic>;
          final segments = vtMap['segments'] as List? ?? [];
          
          final wordTimings = <WordTiming>[];
          for (final seg in segments) {
            if (seg is List && seg.length >= 3) {
              wordTimings.add(WordTiming(
                wordIndex: seg[0] as int,
                startMs: seg[1] as int,
                endMs: seg[2] as int,
              ));
            }
          }

          verseTimings.add(VerseTiming(
            verseKey: vtMap['verse_key'] as String,
            timestampFrom: vtMap['timestamp_from'] as int? ?? 0,
            timestampTo: vtMap['timestamp_to'] as int? ?? 0,
            duration: vtMap['duration'] as int? ?? 0,
            wordTimings: wordTimings,
          ));
        }

        final data = ChapterAudioData(
          audioUrl: audioUrl,
          durationMs: durationMs,
          verseTimings: verseTimings,
        );

        // Cache raw response
        await _cacheBox.put(cacheKey, res.data);
        
        debugPrint('✅ WordTimingService: Loaded ${verseTimings.length} verses with word segments for chapter $chapterNumber');
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('❌ WordTimingService error: $e');
      // Try cache on failure
      final cached = _cacheBox.get(cacheKey);
      if (cached != null) return _parseFromCache(cached);
      return null;
    }
  }

  ChapterAudioData? _parseFromCache(dynamic cached) {
    try {
      final data = cached is Map ? Map<String, dynamic>.from(cached) : null;
      if (data == null) return null;

      final audioFiles = data['audio_files'] as List?;
      if (audioFiles == null || audioFiles.isEmpty) return null;

      final file = Map<String, dynamic>.from(audioFiles[0] as Map);
      final audioUrl = file['audio_url'] as String;
      final durationMs = file['duration'] as int? ?? 0;
      final verseTimingsRaw = file['verse_timings'] as List? ?? [];

      final verseTimings = <VerseTiming>[];
      for (final vt in verseTimingsRaw) {
        final vtMap = Map<String, dynamic>.from(vt as Map);
        final segments = vtMap['segments'] as List? ?? [];

        final wordTimings = <WordTiming>[];
        for (final seg in segments) {
          if (seg is List && seg.length >= 3) {
            wordTimings.add(WordTiming(
              wordIndex: seg[0] as int,
              startMs: seg[1] as int,
              endMs: seg[2] as int,
            ));
          }
        }

        verseTimings.add(VerseTiming(
          verseKey: vtMap['verse_key'] as String,
          timestampFrom: vtMap['timestamp_from'] as int? ?? 0,
          timestampTo: vtMap['timestamp_to'] as int? ?? 0,
          duration: vtMap['duration'] as int? ?? 0,
          wordTimings: wordTimings,
        ));
      }

      return ChapterAudioData(
        audioUrl: audioUrl,
        durationMs: durationMs,
        verseTimings: verseTimings,
      );
    } catch (_) {
      return null;
    }
  }
}
