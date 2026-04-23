import 'package:flutter/material.dart';
import '../../models/ayah.dart';
import '../../models/reading_mode.dart';
import '../../services/tajweed_service.dart';
import './ayah_toolbar.dart';

/// Word-by-Word Ayah Widget
/// Bilkul waise jaisa image mein hai:
/// - Arabic word (bara)
/// - Transliteration (colored)
/// - Urdu/English translation (neeche)
/// - Tajweed colors optional
class WordByWordAyahWidget extends StatelessWidget {
  final Ayah ayah;
  final int surahNumber;
  final ReadingPreferences preferences;
  final bool isBookmarked;
  final VoidCallback onBookmarkToggle;
  final VoidCallback onTafseerTap;

  const WordByWordAyahWidget({
    super.key,
    required this.ayah,
    required this.surahNumber,
    required this.preferences,
    required this.isBookmarked,
    required this.onBookmarkToggle,
    required this.onTafseerTap,
  });

  // Har word ko ek rng — cycle karta rahe (elegant scheme)
  static const List<Color> _wordColors = [
    Color(0xFF0F4C81), // Classic Blue
    Color(0xFF9B1B30), // Deep Red
    Color(0xFF2E4053), // Slate
    Color(0xFF8E44AD), // Muted Purple
    Color(0xFFC0392B), // Brick
    Color(0xFF229954), // Emerald
  ];

  @override
  Widget build(BuildContext context) {
    final words = ayah.ayahWords;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Top Row: Ayah Toolbar ───
          AyahToolbar(
            ayah: ayah,
            surahNumber: surahNumber,
            isBookmarked: isBookmarked,
            onBookmarkToggle: onBookmarkToggle,
            onTafseerTap: onTafseerTap,
          ),

          // ─── Word-by-Word Grid (RTL) ───────────
          if (words != null && words.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: _WordByWordGrid(
                words: words,
                preferences: preferences,
                wordColors: _wordColors,
              ),
            )
          else
          // Fallback: full Arabic text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                ayah.text.cleanArabic,
                style: TextStyle(
                  fontFamily: 'UthmanicHafs',
                  fontSize: preferences.arabicFontSize,
                  height: 2.0,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ),

          // ─── Full Translation at bottom ────────
          if (ayah.translation != null && ayah.translation!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF9FBE7),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Text(
                '(${ayah.numberInSurah}) ${ayah.translation!}',
                textAlign: preferences.selectedTranslation.startsWith('ar') || preferences.selectedTranslation.startsWith('ur') ? TextAlign.right : TextAlign.left,
                textDirection: preferences.selectedTranslation.startsWith('ar') || preferences.selectedTranslation.startsWith('ur') ? TextDirection.rtl : TextDirection.ltr,
                style: TextStyle(
                  fontFamily: preferences.selectedTranslation.startsWith('ur') 
                    ? 'Jameel Noori' 
                    : (preferences.selectedTranslation.startsWith('ar') ? 'DigitalKhatt' : null),
                  fontSize: preferences.selectedTranslation.startsWith('ar') 
                    ? preferences.translationFontSize + 4 
                    : preferences.translationFontSize,
                  height: preferences.selectedTranslation.startsWith('ar') ? 2.0 : 1.6,
                  color: Colors.black87,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Word Grid — image jaise layout ─────────────────────────
class _WordByWordGrid extends StatelessWidget {
  final List<AyahWord> words;
  final ReadingPreferences preferences;
  final List<Color> wordColors;

  const _WordByWordGrid({
    required this.words,
    required this.preferences,
    required this.wordColors,
  });

  @override
  Widget build(BuildContext context) {
    // RTL direction mein words ko wrap karo
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 16,
        children: List.generate(words.length, (index) {
          final word = words[index];
          final color = wordColors[index % wordColors.length];

          return _WordCard(
            word: word,
            color: color,
            arabicFontSize: preferences.arabicFontSize,
            translationFontSize: preferences.translationFontSize,
            showTransliteration: preferences.showTransliteration,
            showTajweed: preferences.showTajweed,
            wbwLanguage: preferences.wbwLanguage,
          );
        }),
      ),
    );
  }
}

// ─── Single Word Card ────────────────────────────────────────
class _WordCard extends StatelessWidget {
  final AyahWord word;
  final Color color;
  final double arabicFontSize;
  final double translationFontSize;
  final bool showTransliteration;
  final bool showTajweed;
  final String wbwLanguage;

  const _WordCard({
    required this.word,
    required this.color,
    required this.arabicFontSize,
    required this.translationFontSize,
    required this.showTransliteration,
    required this.showTajweed,
    required this.wbwLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Arabic word — Tajweed colors ya single color
          if (showTajweed && word.tajweedSegments != null && word.tajweedSegments!.isNotEmpty)
            RichText(
              textDirection: TextDirection.rtl,
              text: TextSpan(
                children: word.tajweedSegments!.map((seg) {
                  return TextSpan(
                    text: seg.text,
                    style: TextStyle(
                      color: TajweedService.getTajweedColor(seg.rule),
                      fontSize: arabicFontSize,
                      fontFamily: 'UthmanicHafs',
                      height: 1.8,
                    ),
                  );
                }).toList(),
              ),
            )
          else
            Text(
              word.arabic.cleanArabic,
              style: TextStyle(
                color: color,
                fontSize: arabicFontSize,
                fontFamily: 'UthmanicHafs',
                height: 1.8,
              ),
              textDirection: TextDirection.rtl,
            ),

          // Transliteration (colored same as Arabic)
          if (showTransliteration && word.transliteration != null)
            Text(
              word.transliteration!,
              style: TextStyle(
                color: color,
                fontSize: translationFontSize - 1,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),

          // Word-level Custom Language Translation
          if (word.translation != null && word.translation!.isNotEmpty)
            Text(
              word.translation!,
              style: TextStyle(
                fontFamily: wbwLanguage.startsWith('ur') ? 'Jameel Noori' : (wbwLanguage.startsWith('ar') ? 'DigitalKhatt' : null),
                color: Colors.black54,
                fontWeight: FontWeight.w500,
                fontSize: wbwLanguage.startsWith('ar') ? translationFontSize : translationFontSize - 2,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.visible,
              textDirection: wbwLanguage.startsWith('ur') || wbwLanguage.startsWith('ar') ? TextDirection.rtl : TextDirection.ltr,
            ),
        ],
      ),
    );
  }
}