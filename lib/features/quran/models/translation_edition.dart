/// Represents a language with its display name and flag emoji
class LanguageInfo {
  final String displayName;
  const LanguageInfo(this.displayName);
}

/// Maps 2-letter language codes to human-readable names.
/// Priority languages (Urdu, Arabic, English) are marked separately
/// so they appear at the top of the selection screen.
const List<String> priorityLanguages = ['ur', 'ar', 'en'];

const Map<String, LanguageInfo> languageInfoMap = {
  // ─── Priority Languages ────────────────────────
  'ur': LanguageInfo('اردو (Urdu)'),
  'ar': LanguageInfo('العربية (Arabic)'),
  'en': LanguageInfo('English'),
  // ─── Alphabetical — remaining languages ────────
  'am': LanguageInfo('አማርኛ (Amharic)'),
  'az': LanguageInfo('Azərbaycanca (Azerbaijani)'),
  'ba': LanguageInfo('Bosnian (alt)'),
  'ber': LanguageInfo('Berber (Tamazight)'),
  'bg': LanguageInfo('Български (Bulgarian)'),
  'bn': LanguageInfo('বাংলা (Bengali)'),
  'bs': LanguageInfo('Bosanski (Bosnian)'),
  'ce': LanguageInfo('Нохчийн (Chechen)'),
  'cs': LanguageInfo('Čeština (Czech)'),
  'de': LanguageInfo('Deutsch (German)'),
  'dv': LanguageInfo('ދિވެހި (Divehi)'),
  'es': LanguageInfo('Español (Spanish)'),
  'fa': LanguageInfo('فارسی (Persian)'),
  'fr': LanguageInfo('Français (French)'),
  'ha': LanguageInfo('Hausa'),
  'hi': LanguageInfo('हिन्दी (Hindi)'),
  'id': LanguageInfo('Bahasa Indonesia'),
  'it': LanguageInfo('Italiano (Italian)'),
  'ja': LanguageInfo('日本語 (Japanese)'),
  'ko': LanguageInfo('한국어 (Korean)'),
  'ku': LanguageInfo('Kurdî (Kurdish)'),
  'ml': LanguageInfo('മലയാളം (Malayalam)'),
  'ms': LanguageInfo('Bahasa Melayu (Malay)'),
  'my': LanguageInfo('မြန်မာ (Burmese)'),
  'nl': LanguageInfo('Nederlands (Dutch)'),
  'no': LanguageInfo('Norsk (Norwegian)'),
  'pl': LanguageInfo('Polski (Polish)'),
  'ps': LanguageInfo('پښتو (Pashto)'),
  'pt': LanguageInfo('Português (Portuguese)'),
  'ro': LanguageInfo('Română (Romanian)'),
  'ru': LanguageInfo('Русский (Russian)'),
  'sd': LanguageInfo('سنڌي (Sindhi)'),
  'si': LanguageInfo('සිංහල (Sinhala)'),
  'so': LanguageInfo('Soomaali (Somali)'),
  'sq': LanguageInfo('Shqip (Albanian)'),
  'sv': LanguageInfo('Svenska (Swedish)'),
  'sw': LanguageInfo('Kiswahili (Swahili)'),
  'ta': LanguageInfo('தமிழ் (Tamil)'),
  'tg': LanguageInfo('Тоҷикӣ (Tajik)'),
  'th': LanguageInfo('ภาษาไทย (Thai)'),
  'tr': LanguageInfo('Türkçe (Turkish)'),
  'tt': LanguageInfo('Татарча (Tatar)'),
  'ug': LanguageInfo('ئۇيغۇرچە (Uyghur)'),
  'uz': LanguageInfo('Oʻzbekcha (Uzbek)'),
  'zh': LanguageInfo('中文 (Chinese)'),
};

class TranslationEdition {
  final String identifier;
  final String language;
  final String name;
  final String englishName;
  final String format;
  final String direction;

  const TranslationEdition({
    required this.identifier,
    required this.language,
    required this.name,
    required this.englishName,
    required this.format,
    required this.direction,
  });

  factory TranslationEdition.fromJson(Map<String, dynamic> json) {
    return TranslationEdition(
      identifier: json['identifier'] as String,
      language: json['language'] as String,
      name: json['name'] as String,
      englishName: json['englishName'] as String,
      format: json['format'] as String,
      direction: json['direction'] as String? ?? 'ltr',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'language': language,
      'name': name,
      'englishName': englishName,
      'format': format,
      'direction': direction,
    };
  }

  /// Get display info for this edition's language
  LanguageInfo get languageInfo =>
      languageInfoMap[language] ?? LanguageInfo(language.toUpperCase());
}
