/// Represents a verse-by-verse translation audio edition that has
/// both per-ayah audio AND a matching text edition.
///
/// CRITICAL: The [audioEditionId] and [textEditionId] MUST come from the same
/// translation so that the text shown exactly matches what is being heard.
///
/// Audio CDN: https://cdn.islamic.network/quran/audio/128/{audioEditionId}/{globalAyahNumber}.mp3
/// Text API:  https://api.alquran.cloud/v1/ayah/{surah}:{ayah}/{textEditionId}
class TranslationAudioEdition {
  final String id;
  final String audioEditionId;
  final String textEditionId;
  final String language;
  final String readerName;
  final String translatorName;
  final String languageLabel;
  final String flagEmoji;
  final bool isRtl;

  const TranslationAudioEdition({
    required this.id,
    required this.audioEditionId,
    required this.textEditionId,
    required this.language,
    required this.readerName,
    required this.translatorName,
    required this.languageLabel,
    required this.flagEmoji,
    this.isRtl = false,
  });

  /// Returns the CDN URL for a specific global ayah number (1–6236).
  /// Uses cdn.alquran.cloud which hosts translation audio editions
  /// (ur.khan, en.walk, fr.leclerc, etc.). The islamic.network CDN
  /// only serves Arabic recitations and returns 403 for these editions.
  String getAyahAudioUrl(int globalAyahNumber, {int bitrate = 128}) {
    return 'https://cdn.alquran.cloud/media/audio/ayah/$audioEditionId/$globalAyahNumber';
  }

  /// Returns the AlQuran.cloud text API URL for a specific ayah.
  String getAyahTextUrl(int surahNumber, int ayahInSurah) {
    return 'https://api.alquran.cloud/v1/ayah/$surahNumber:$ayahInSurah/$textEditionId';
  }

  // ═══════════════════════════════════════════════════════════
  // ALL AVAILABLE VERSE-BY-VERSE TRANSLATION AUDIO EDITIONS
  // Verified: audio CDN exists + matching text edition confirmed
  // ═══════════════════════════════════════════════════════════
  static const List<TranslationAudioEdition> availableEditions = [
    // ── اردو (Urdu) ───────────────────────────────────────
    // ur.khan = Shamshad Ali Khan reading Jalandhari's translation
    // ur.jalandhry = Fateh Muhammad Jalandhari text (same content)
    TranslationAudioEdition(
      id: 'ur-jalandhri',
      audioEditionId: 'ur.khan',
      textEditionId: 'ur.jalandhry',
      language: 'ur',
      readerName: 'Shamshad Ali Khan',
      translatorName: 'Fateh Muhammad Jalandhry',
      languageLabel: 'اردو — جالندھری',
      flagEmoji: '🇵🇰',
      isRtl: true,
    ),

    // ── English ────────────────────────────────────────────
    TranslationAudioEdition(
      id: 'en-sahih',
      audioEditionId: 'en.walk',
      textEditionId: 'en.sahih',
      language: 'en',
      readerName: 'Ibrahim Walk',
      translatorName: 'Saheeh International',
      languageLabel: 'English — Saheeh International',
      flagEmoji: '🇬🇧',
      isRtl: false,
    ),

    // ── Français (French) ─────────────────────────────────
    TranslationAudioEdition(
      id: 'fr-hamidullah',
      audioEditionId: 'fr.leclerc',
      textEditionId: 'fr.hamidullah',
      language: 'fr',
      readerName: 'Youssouf Leclerc',
      translatorName: 'Muhammad Hamidullah',
      languageLabel: 'Français — Hamidullah',
      flagEmoji: '🇫🇷',
      isRtl: false,
    ),

    // ── 中文 (Chinese) ────────────────────────────────────
    TranslationAudioEdition(
      id: 'zh-majian',
      audioEditionId: 'zh.chinese',
      textEditionId: 'zh.majian',
      language: 'zh',
      readerName: 'Chinese Reader',
      translatorName: 'Ma Jian',
      languageLabel: '中文 — 马坚',
      flagEmoji: '🇨🇳',
      isRtl: false,
    ),

    // ── Русский (Russian) ─────────────────────────────────
    TranslationAudioEdition(
      id: 'ru-kuliev',
      audioEditionId: 'ru.kuliev-audio',
      textEditionId: 'ru.kuliev',
      language: 'ru',
      readerName: 'Elmir Kuliev',
      translatorName: 'Elmir Kuliev',
      languageLabel: 'Русский — Кулиев',
      flagEmoji: '🇷🇺',
      isRtl: false,
    ),

    // ── Қазақ (Kazakh) ───────────────────────────────────
    TranslationAudioEdition(
      id: 'kk-altai',
      audioEditionId: 'kk.khalifahaltai-audio',
      textEditionId: 'kk.khalifahaltai',
      language: 'kk',
      readerName: 'Khalifah Altai',
      translatorName: 'Khalifah Altai',
      languageLabel: 'Қазақ — Халифа Алтай',
      flagEmoji: '🇰🇿',
      isRtl: false,
    ),
  ];

  /// Default edition — Urdu Jalandhari
  static TranslationAudioEdition get defaultEdition => availableEditions.first;

  /// Find edition by ID
  static TranslationAudioEdition? findById(String id) {
    try {
      return availableEditions.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
