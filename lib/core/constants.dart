//====================================
// tasbeeh constant
//======================================
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════
//   GOLDEN THEME COLORS
// ═══════════════════════════════════════════

class TasbeehColors {
  // Core Golds
  static const Color standardGold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFFFD28A);
  static const Color goldDeep = Color(0xFFFFAA5A);
  static const Color darkerGold = Color(0xFFB8960C);
  static const Color softGold = Color(0xFFFFFDF5);
  static const Color bronzeGold = Color(0xFF948160);
  static const Color goldenCream = Color(0xFFF5F0D5);
  static const Color goldenCream2 = Color(0xFFE8D8A8);
  static const Color amberGold = Color(0xFFFFC107);

  // Backgrounds
  static const Color background = Color(0xFFFFFDF5);        // softGold
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceGold = Color(0xFFF5F0D5);       // goldenCream

  // Text
  static const Color textPrimary = Color(0xFF2C2415);
  static const Color textSecondary = Color(0xFF6B5B35);
  static const Color textLight = Color(0xFF948160);          // bronzeGold

  // Gradient stops
  static const List<Color> goldGradient = [
    Color(0xFFFFD28A),  // goldLight
    Color(0xFFD4AF37),  // standardGold
    Color(0xFFB8960C),  // darkerGold
  ];

  static const List<Color> softGradient = [
    Color(0xFFFFFDF5),  // softGold
    Color(0xFFF5F0D5),  // goldenCream
    Color(0xFFE8D8A8),  // goldenCream2
  ];

  static LinearGradient get primaryGradient => const LinearGradient(
    colors: goldGradient,
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get backgroundGradient => const LinearGradient(
    colors: [Color(0xFFFFFDF5), Color(0xFFF5F0D5)],
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