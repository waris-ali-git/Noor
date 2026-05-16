//====================================
// tasbeeh constant
//======================================
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════
//   PASTEL LIGHT BLUE THEME COLORS
// ═══════════════════════════════════════════

class TasbeehColors {
  // Core Blues  (replaces the old gold palette)
  static const Color standardBlue  = Color(0xFF90BDE7); // Carolina Blue   — was standardGold
  static const Color blueLight     = Color(0xFFD9F1FD); // Powder Blue     — was goldLight
  static const Color blueMid       = Color(0xFFA6C7F2); // Baby Blue       — was goldDeep
  static const Color blueDark      = Color(0xFF6FA8D8); // deeper Carolina — was darkerGold
  static const Color iceWhite      = Color(0xFFFAFDFF); // Ice White       — was softGold
  static const Color steelBlue     = Color(0xFF6B8FB5); // muted steel     — was bronzeGold
  static const Color whisperBlue   = Color(0xFFDBE9FA); // Whisper Blue    — was goldenCream
  static const Color babyBlue      = Color(0xFFA6C7F2); // Baby Blue       — was goldenCream2
  static const Color skyBlue       = Color(0xFF90BDE7); // sky accent      — was amberGold

  // Backgrounds
  static const Color background    = Color(0xFFFAFDFF); // iceWhite        — was softGold bg
  static const Color surface       = Color(0xFFFAFDFF); // iceWhite        — was pure white
  static const Color surfaceBlue   = Color(0xFFDBE9FA); // whisperBlue     — was goldenCream surface

  // Text  (kept neutral so Arabic text stays readable)
  static const Color textPrimary   = Color(0xFF1A2E44); // deep navy
  static const Color textSecondary = Color(0xFF4A6B8A); // muted blue-grey
  static const Color textLight     = Color(0xFF6B8FB5); // steelBlue

  // Gradient stops
  static const List<Color> blueGradient = [
    Color(0xFFD9F1FD),  // blueLight  (Powder Blue)
    Color(0xFF90BDE7),  // standardBlue (Carolina Blue)
    Color(0xFF6FA8D8),  // blueDark
  ];

  static const List<Color> softGradient = [
    Color(0xFFFAFDFF),  // iceWhite
    Color(0xFFDBE9FA),  // whisperBlue
    Color(0xFFA6C7F2),  // babyBlue
  ];

  static LinearGradient get primaryGradient => const LinearGradient(
    colors: blueGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get backgroundGradient => const LinearGradient(
    colors: [Color(0xFFFAFDFF), Color(0xFFDBE9FA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

// ═══════════════════════════════════════════
//   TEXT STYLES
// ═══════════════════════════════════════════

class TasbeehTextStyles {
  static const String arabicFont = 'Amiri';   // Add to pubspec.yaml

  static TextStyle arabicLarge(double fontSize) => TextStyle(
    fontFamily: arabicFont,
    fontSize: fontSize,
    color: TasbeehColors.textPrimary,
    height: 1.6,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle counterDisplay = TextStyle(
    fontSize: 72,
    fontWeight: FontWeight.w200,
    color: TasbeehColors.textPrimary,
    letterSpacing: -2,
    height: 1,
  );

  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: TasbeehColors.textPrimary,
    letterSpacing: 0.3,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: TasbeehColors.textSecondary,
    letterSpacing: 0.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: TasbeehColors.textLight,
    letterSpacing: 0.3,
  );
}

// ═══════════════════════════════════════════
//   PRESET DHIKR LIST
// ═══════════════════════════════════════════

const List<Map<String, dynamic>> kPresetDhikr = [
  {
    'id': 'subhanallah',
    'name': 'SubhanAllah',
    'arabicText': 'سُبْحَانَ اللهِ',
    'transliteration': 'SubhanAllah',
    'translation': 'Glory be to Allah',
    'targetCount': 33,
    'category': 'Tasbih',
  },
  {
    'id': 'alhamdulillah',
    'name': 'Alhamdulillah',
    'arabicText': 'الْحَمْدُ لِلَّهِ',
    'transliteration': 'Alhamdulillah',
    'translation': 'All praise is due to Allah',
    'targetCount': 33,
    'category': 'Tasbih',
  },
  {
    'id': 'allahuakbar',
    'name': 'Allahu Akbar',
    'arabicText': 'اللهُ أَكْبَرُ',
    'transliteration': 'Allahu Akbar',
    'translation': 'Allah is the Greatest',
    'targetCount': 34,
    'category': 'Tasbih',
  },
  {
    'id': 'lailahaillallah',
    'name': 'La ilaha illAllah',
    'arabicText': 'لَا إِلَٰهَ إِلَّا اللَّٰهُ',
    'transliteration': 'La ilaha illAllah',
    'translation': 'There is no god but Allah',
    'targetCount': 100,
    'category': 'Tahlil',
  },
  {
    'id': 'astaghfirullah',
    'name': 'Astaghfirullah',
    'arabicText': 'أَسْتَغْفِرُ اللهَ',
    'transliteration': 'Astaghfirullah',
    'translation': 'I seek forgiveness from Allah',
    'targetCount': 100,
    'category': 'Istighfar',
  },
  {
    'id': 'salawat',
    'name': 'Salawat',
    'arabicText': 'اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ',
    'transliteration': 'Allahumma salli ala Muhammad',
    'translation': 'O Allah, send blessings upon Muhammad ﷺ',
    'targetCount': 100,
    'category': 'Salawat',
  },
  {
    'id': 'hasbunallah',
    'name': 'HasbunAllah',
    'arabicText': 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
    'transliteration': 'HasbunAllahu wa ni\'mal wakil',
    'translation': 'Allah is sufficient for us and the best Guardian',
    'targetCount': 40,
    'category': 'Dua',
  },
  {
    'id': 'hawqala',
    'name': 'La Hawla',
    'arabicText': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    'transliteration': 'La hawla wa la quwwata illa billah',
    'translation': 'There is no power except with Allah',
    'targetCount': 100,
    'category': 'Hawqala',
  },
];

const List<String> kCategories = [
  'All',
  'Tasbih',
  'Tahlil',
  'Istighfar',
  'Salawat',
  'Dua',
  'Hawqala',
  'Custom',
];