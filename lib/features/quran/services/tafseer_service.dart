import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import '../models/tafseer_source.dart';

class TafseerAudioSegment {
  final int part;
  final int surah;
  final int startAyah; // inclusive
  final int? endAyah; // inclusive, null => till end of surah
  final String title;
  final String url;

  const TafseerAudioSegment({
    required this.part,
    required this.surah,
    required this.startAyah,
    required this.endAyah,
    required this.title,
    required this.url,
  });

  bool containsAyah(int ayahNumber) {
    if (ayahNumber < startAyah) return false;
    if (endAyah == null) return true;
    return ayahNumber <= endAyah!;
  }
}

class TafseerService {
  final Dio _dio;
  final Box<dynamic> _cacheBox;

  static const String _baseUrl = 'https://cdn.jsdelivr.net/gh/spa5k/tafsir_api@main/tafsir';
  static const String _tanzeemBase = 'https://media.tanzeem.org/audios/004/04-198/';
  static const String _quranComBase = 'https://api.quran.com/api/v4';

  // Dora Tarjuma Quran 1998 (Audio Code 04-198) — Dr. Israr Ahmed (Tanzeem.org)
  // NOTE: This is **not** 1 file per ayah. It's segmented by ayah ranges.
  // We map every surah/ayah-range to its corresponding segment URL.
  static const List<TafseerAudioSegment> _tanzeemSegments = [
    // --- SURAH AL-FATIHAH (1) ---
    TafseerAudioSegment(part: 5, surah: 1, startAyah: 1, endAyah: null, title: 'Part 05 | Al-Fatihah', url: '${_tanzeemBase}005-Al-Fatehah.mp3'),

    // --- SURAH AL-BAQARAH (2) ---
    TafseerAudioSegment(part: 6, surah: 2, startAyah: 1, endAyah: 29, title: 'Part 06 | Al-Baqarah (1-29)', url: '${_tanzeemBase}006-Al-Baqarah(1-29).mp3'),
    TafseerAudioSegment(part: 7, surah: 2, startAyah: 30, endAyah: 46, title: 'Part 07 | Al-Baqarah (30-46)', url: '${_tanzeemBase}007-Al-Baqarah(30-46).mp3'),
    TafseerAudioSegment(part: 8, surah: 2, startAyah: 47, endAyah: 74, title: 'Part 08 | Al-Baqarah (47-74)', url: '${_tanzeemBase}008-Al-Baqarah(47-74).mp3'),
    TafseerAudioSegment(part: 9, surah: 2, startAyah: 75, endAyah: 107, title: 'Part 09 | Al-Baqarah (75-107)', url: '${_tanzeemBase}009-Al-Baqarah(75-107).mp3'),
    TafseerAudioSegment(part: 10, surah: 2, startAyah: 108, endAyah: 141, title: 'Part 10 | Al-Baqarah (108-141)', url: '${_tanzeemBase}010-Al-Baqarah(108-141).mp3'),
    TafseerAudioSegment(part: 11, surah: 2, startAyah: 142, endAyah: 176, title: 'Part 11 | Al-Baqarah (142-176)', url: '${_tanzeemBase}011-Al-Baqarah(142-176).mp3'),
    TafseerAudioSegment(part: 12, surah: 2, startAyah: 177, endAyah: 196, title: 'Part 12 | Al-Baqarah (177-196)', url: '${_tanzeemBase}012-Al-Baqarah(177-196).mp3'),
    TafseerAudioSegment(part: 13, surah: 2, startAyah: 197, endAyah: 228, title: 'Part 13 | Al-Baqarah (197-228)', url: '${_tanzeemBase}013-Al-Baqarah(197-228).mp3'),
    TafseerAudioSegment(part: 14, surah: 2, startAyah: 229, endAyah: 253, title: 'Part 14 | Al-Baqarah (229-253)', url: '${_tanzeemBase}014-Al-Baqarah(229-253).mp3'),
    TafseerAudioSegment(part: 15, surah: 2, startAyah: 254, endAyah: 273, title: 'Part 15 | Al-Baqarah (254-273)', url: '${_tanzeemBase}015-Al-Baqarah(254-273).mp3'),
    TafseerAudioSegment(part: 16, surah: 2, startAyah: 274, endAyah: null, title: 'Part 16 | Al-Baqarah (274-End)', url: '${_tanzeemBase}016-Al-Baqarah(274-End).mp3'),

    // --- SURAH AAL-E-IMRAN (3) ---
    TafseerAudioSegment(part: 17, surah: 3, startAyah: 1, endAyah: 48, title: 'Part 17 | Aal-e-Imran (1-48)', url: '${_tanzeemBase}017-Aal-e-Imran(1-48).mp3'),
    TafseerAudioSegment(part: 18, surah: 3, startAyah: 49, endAyah: 101, title: 'Part 18 | Aal-e-Imran (49-101)', url: '${_tanzeemBase}018-Aal-e-Imran(49-101).mp3'),
    TafseerAudioSegment(part: 19, surah: 3, startAyah: 102, endAyah: 151, title: 'Part 19 | Aal-e-Imran (102-151)', url: '${_tanzeemBase}019-Aal-e-Imran(102-151).mp3'),
    TafseerAudioSegment(part: 20, surah: 3, startAyah: 152, endAyah: null, title: 'Part 20 | Aal-e-Imran (152-End)', url: '${_tanzeemBase}020-Aal-e-Imran(152-End).mp3'),

    // --- SURAH AN-NISA (4) ---
    TafseerAudioSegment(part: 21, surah: 4, startAyah: 1, endAyah: 30, title: 'Part 21 | An-Nisa (1-30)', url: '${_tanzeemBase}021-An-Nisa(1-30).mp3'),
    TafseerAudioSegment(part: 22, surah: 4, startAyah: 31, endAyah: 65, title: 'Part 22 | An-Nisa (31-65)', url: '${_tanzeemBase}022-An-Nisa(31-65).mp3'),
    TafseerAudioSegment(part: 23, surah: 4, startAyah: 66, endAyah: 100, title: 'Part 23 | An-Nisa (66-100)', url: '${_tanzeemBase}023-An-Nisa(66-100).mp3'),
    TafseerAudioSegment(part: 24, surah: 4, startAyah: 101, endAyah: 142, title: 'Part 24 | An-Nisa (101-142)', url: '${_tanzeemBase}024-An-Nisa(101-142).mp3'),
    TafseerAudioSegment(part: 25, surah: 4, startAyah: 143, endAyah: null, title: 'Part 25 | An-Nisa (143-End) + Al-Maidah (1-4)', url: '${_tanzeemBase}025-An-Nisa(143)Al-Maidah-4.mp3'),

    // --- SURAH AL-MAIDAH (5) ---
    // Part 25 spans Surah 4 and Surah 5, so we map it here too.
    TafseerAudioSegment(part: 25, surah: 5, startAyah: 1, endAyah: 4, title: 'Part 25 | An-Nisa (143-End) + Al-Maidah (1-4)', url: '${_tanzeemBase}025-An-Nisa(143)Al-Maidah-4.mp3'),
    TafseerAudioSegment(part: 26, surah: 5, startAyah: 5, endAyah: 43, title: 'Part 26 | Al-Maidah (5-43)', url: '${_tanzeemBase}026-Al-Maidah(5-43).mp3'),
    TafseerAudioSegment(part: 27, surah: 5, startAyah: 44, endAyah: 86, title: 'Part 27 | Al-Maidah (44-86)', url: '${_tanzeemBase}027-Al-Maidah(44-86).mp3'),
    TafseerAudioSegment(part: 28, surah: 5, startAyah: 87, endAyah: null, title: 'Part 28 | Al-Maidah (87-End)', url: '${_tanzeemBase}028-Al-Maidah(87-End).mp3'),

    // --- SURAH AL-ANAM (6) ---
    TafseerAudioSegment(part: 29, surah: 6, startAyah: 1, endAyah: 49, title: 'Part 29 | Al-Anam (1-49)', url: '${_tanzeemBase}029-Al-Anam(1-49).mp3'),
    TafseerAudioSegment(part: 30, surah: 6, startAyah: 50, endAyah: 90, title: 'Part 30 | Al-Anam (50-90)', url: '${_tanzeemBase}030-Al-Anam(50-90).mp3'),
    TafseerAudioSegment(part: 31, surah: 6, startAyah: 91, endAyah: 129, title: 'Part 31 | Al-Anam (91-129)', url: '${_tanzeemBase}031-Al-Anam(91-129).mp3'),
    TafseerAudioSegment(part: 32, surah: 6, startAyah: 130, endAyah: null, title: 'Part 32 | Al-Anam (130-End) + Al-Araf (1-19)', url: '${_tanzeemBase}032-Al-Anam(130)Al-Araf(19).mp3'),

    // --- SURAH AL-ARAF (7) ---
    // Part 32 spans Surah 6 and Surah 7, so we map it here too.
    TafseerAudioSegment(part: 32, surah: 7, startAyah: 1, endAyah: 19, title: 'Part 32 | Al-Anam (130-End) + Al-Araf (1-19)', url: '${_tanzeemBase}032-Al-Anam(130)Al-Araf(19).mp3'),
    TafseerAudioSegment(part: 33, surah: 7, startAyah: 20, endAyah: 58, title: 'Part 33 | Al-Araf (20-58)', url: '${_tanzeemBase}033-Al-Araf(20-58).mp3'),
    TafseerAudioSegment(part: 34, surah: 7, startAyah: 59, endAyah: 129, title: 'Part 34 | Al-Araf (59-129)', url: '${_tanzeemBase}034-Al-Araf(59-129).mp3'),
    TafseerAudioSegment(part: 35, surah: 7, startAyah: 130, endAyah: 166, title: 'Part 35 | Al-Araf (130-166)', url: '${_tanzeemBase}035-Al-Araf(130-166).mp3'),
    TafseerAudioSegment(part: 36, surah: 7, startAyah: 167, endAyah: null, title: 'Part 36 | Al-Araf (167-End)', url: '${_tanzeemBase}036-Al-Araf(167-End).mp3'),

    // --- SURAH AL-ANFAL (8) ---
    TafseerAudioSegment(part: 37, surah: 8, startAyah: 1, endAyah: 40, title: 'Part 37 | Al-Anfal (1-40)', url: '${_tanzeemBase}037-Al-Anfal(1-40).mp3'),
    TafseerAudioSegment(part: 38, surah: 8, startAyah: 41, endAyah: null, title: 'Part 38 | Al-Anfal (41-End)', url: '${_tanzeemBase}038-Al-Anfal(41-End).mp3'),

    // --- SURAH AT-TAUBAH (9) ---
    TafseerAudioSegment(part: 39, surah: 9, startAyah: 1, endAyah: 34, title: 'Part 39 | At-Taubah (1-34)', url: '${_tanzeemBase}039-At-Taubah(1-34).mp3'),
    TafseerAudioSegment(part: 40, surah: 9, startAyah: 35, endAyah: 85, title: 'Part 40 | At-Taubah (35-85)', url: '${_tanzeemBase}040-At-Taubah(35-85).mp3'),
    TafseerAudioSegment(part: 41, surah: 9, startAyah: 86, endAyah: null, title: 'Part 41 | At-Taubah (86-End)', url: '${_tanzeemBase}041-At-Taubah(86-End).mp3'),

    // --- SURAH YOUNUS (10) ---
    TafseerAudioSegment(part: 42, surah: 10, startAyah: 1, endAyah: null, title: 'Part 42 | Surah Younus', url: '${_tanzeemBase}042-Surah-Younus.mp3'),

    // --- SURAH HOOD (11) ---
    TafseerAudioSegment(part: 43, surah: 11, startAyah: 1, endAyah: null, title: 'Part 43 | Surah Hood', url: '${_tanzeemBase}043-Surah-Hood.mp3'),

    // --- SURAH YOUSUF (12) ---
    TafseerAudioSegment(part: 44, surah: 12, startAyah: 1, endAyah: null, title: 'Part 44 | Surah Yousuf', url: '${_tanzeemBase}044-Surah-Yousuf.mp3'),

    // --- SURAH AR-RAAD (13) ---
    TafseerAudioSegment(part: 45, surah: 13, startAyah: 1, endAyah: null, title: 'Part 45 | Surah Ar-Raad', url: '${_tanzeemBase}045-Surah-Ar-Raad.mp3'),

    // --- SURAH IBRAHEEM (14) ---
    TafseerAudioSegment(part: 46, surah: 14, startAyah: 1, endAyah: null, title: 'Part 46 | Surah Ibraheem', url: '${_tanzeemBase}046-Surah-Ibraheem.mp3'),

    // --- SURAH AL-HIJR (15) ---
    TafseerAudioSegment(part: 47, surah: 15, startAyah: 1, endAyah: null, title: 'Part 47 | Surah Al-Hijr', url: '${_tanzeemBase}047-Surah-Al-Hijr.mp3'),

    // --- SURAH AN-NAHL (16) ---
    TafseerAudioSegment(part: 48, surah: 16, startAyah: 1, endAyah: 65, title: 'Part 48 | An-Nahl (1-65)', url: '${_tanzeemBase}048-An-Nahl(1-65).mp3'),
    TafseerAudioSegment(part: 49, surah: 16, startAyah: 66, endAyah: null, title: 'Part 49 | An-Nahl (66-End)', url: '${_tanzeemBase}049-An-Nahl(66-End).mp3'),

    // --- SURAH BANI ISRAEEL / AL-ISRA (17) ---
    TafseerAudioSegment(part: 50, surah: 17, startAyah: 1, endAyah: null, title: 'Part 50 | Bani Israeel', url: '${_tanzeemBase}050-Bani-Israeel.mp3'),

    // --- SURAH AL-KAHF (18) ---
    TafseerAudioSegment(part: 52, surah: 18, startAyah: 1, endAyah: null, title: 'Part 52 | Surah Al-Kahf', url: '${_tanzeemBase}050-Surah-Al-Kahf.mp3'),

    // --- SURAH MARYAM (19) ---
    TafseerAudioSegment(part: 53, surah: 19, startAyah: 1, endAyah: null, title: 'Part 53 | Surah Maryam', url: '${_tanzeemBase}051-Surah-Maryam.mp3'),

    // --- SURAH TA-HA (20) ---
    TafseerAudioSegment(part: 54, surah: 20, startAyah: 1, endAyah: null, title: 'Part 54 | Surah Ta-Ha', url: '${_tanzeemBase}052-Surah-Taahaa.mp3'),

    // --- SURAH AL-ANBIYA (21) ---
    TafseerAudioSegment(part: 55, surah: 21, startAyah: 1, endAyah: null, title: 'Part 55 | Surah Al-Anbiya', url: '${_tanzeemBase}053-Surah-Al-Ambia.mp3'),

    // --- SURAH AL-HAJJ (22) ---
    TafseerAudioSegment(part: 56, surah: 22, startAyah: 1, endAyah: null, title: 'Part 56 | Surah Al-Hajj', url: '${_tanzeemBase}054-Surah-Al-Hajj.mp3'),

    // --- SURAH AL-MOMINUN (23) ---
    TafseerAudioSegment(part: 57, surah: 23, startAyah: 1, endAyah: null, title: 'Part 57 | Surah Al-Mominun', url: '${_tanzeemBase}055-Surah-Al-Mominun.mp3'),

    // --- SURAH AN-NOOR (24) ---
    TafseerAudioSegment(part: 58, surah: 24, startAyah: 1, endAyah: null, title: 'Part 58 | Surah An-Noor', url: '${_tanzeemBase}056-Surah-An-Noor.mp3'),

    // --- SURAH AL-FURQAN (25) ---
    TafseerAudioSegment(part: 59, surah: 25, startAyah: 1, endAyah: null, title: 'Part 59 | Surah Al-Furqan', url: '${_tanzeemBase}057-Surah-Al-Furqan.mp3'),

    // --- SURAH ASH-SHUARA (26) ---
    TafseerAudioSegment(part: 60, surah: 26, startAyah: 1, endAyah: null, title: 'Part 60 | Surah Ash-Shuara', url: '${_tanzeemBase}058-Surah-Ash-Shuara.mp3'),

    // --- SURAH AN-NAML (27) ---
    TafseerAudioSegment(part: 61, surah: 27, startAyah: 1, endAyah: null, title: 'Part 61 | Surah An-Naml', url: '${_tanzeemBase}059-Surah-An-Naml.mp3'),

    // --- SURAH AL-QASAS (28) ---
    TafseerAudioSegment(part: 62, surah: 28, startAyah: 1, endAyah: null, title: 'Part 62 | Surah Al-Qasas', url: '${_tanzeemBase}060-Surah-Al-Qassas.mp3'),

    // --- SURAH AL-ANKABOOT (29) ---
    TafseerAudioSegment(part: 63, surah: 29, startAyah: 1, endAyah: null, title: 'Part 63 | Surah Al-Ankaboot', url: '${_tanzeemBase}061-Surah-Ankaboot.mp3'),

    // --- SURAH AR-ROOM (30) ---
    TafseerAudioSegment(part: 64, surah: 30, startAyah: 1, endAyah: null, title: 'Part 64 | Surah Ar-Room', url: '${_tanzeemBase}062-Surah-Room.mp3'),

    // --- SURAH LUQMAN (31) ---
    TafseerAudioSegment(part: 65, surah: 31, startAyah: 1, endAyah: null, title: 'Part 65 | Surah Luqman', url: '${_tanzeemBase}063-Surah-Luqman.mp3'),

    // --- SURAH AS-SAJDAH (32) ---
    TafseerAudioSegment(part: 66, surah: 32, startAyah: 1, endAyah: null, title: 'Part 66 | Surah As-Sajdah', url: '${_tanzeemBase}064-Surah-Sajdah.mp3'),

    // --- SURAH AL-AHZAB (33) ---
    TafseerAudioSegment(part: 67, surah: 33, startAyah: 1, endAyah: null, title: 'Part 67 | Surah Al-Ahzab', url: '${_tanzeemBase}065-Surah-Al-Ahzab.mp3'),

    // --- SURAH SABA (34) ---
    TafseerAudioSegment(part: 68, surah: 34, startAyah: 1, endAyah: null, title: 'Part 68 | Surah Saba', url: '${_tanzeemBase}066-Surah-Saba.mp3'),

    // --- SURAH FATIR (35) ---
    TafseerAudioSegment(part: 69, surah: 35, startAyah: 1, endAyah: null, title: 'Part 69 | Surah Fatir', url: '${_tanzeemBase}067-Surah-Fatir.mp3'),

    // --- SURAH YASIN (36) ---
    TafseerAudioSegment(part: 70, surah: 36, startAyah: 1, endAyah: null, title: 'Part 70 | Surah Yasin', url: '${_tanzeemBase}068-Surah-Yaassen.mp3'),

    // --- SURAH AS-SAFFAT (37) ---
    TafseerAudioSegment(part: 71, surah: 37, startAyah: 1, endAyah: null, title: 'Part 71 | Surah As-Saffat', url: '${_tanzeemBase}069-Surah-Saafat.mp3'),

    // --- SURAH SAAD (38) ---
    TafseerAudioSegment(part: 72, surah: 38, startAyah: 1, endAyah: null, title: 'Part 72 | Surah Saad', url: '${_tanzeemBase}070-Surah-Saad.mp3'),

    // --- SURAH AZ-ZUMAR (39) ---
    TafseerAudioSegment(part: 73, surah: 39, startAyah: 1, endAyah: null, title: 'Part 73 | Surah Az-Zumar', url: '${_tanzeemBase}071-Surah-Zumar.mp3'),

    // --- SURAH AL-MOMIN / GHAFIR (40) ---
    TafseerAudioSegment(part: 74, surah: 40, startAyah: 1, endAyah: null, title: 'Part 74 | Surah Al-Momin', url: '${_tanzeemBase}072-Surah-Momin.mp3'),

    // --- SURAH HA-MEEM AS-SAJDAH / FUSSILAT (41) ---
    TafseerAudioSegment(part: 75, surah: 41, startAyah: 1, endAyah: null, title: 'Part 75 | Surah Ha-Meem As-Sajdah', url: '${_tanzeemBase}073-Surah-Haamem-As-Sajdah.mp3'),

    // --- SURAH ASH-SHURA (42) ---
    TafseerAudioSegment(part: 76, surah: 42, startAyah: 1, endAyah: null, title: 'Part 76 | Surah Ash-Shura', url: '${_tanzeemBase}074-Surah-Ash-Shura.mp3'),

    // --- SURAH AZ-ZUKHRUF (43) ---
    TafseerAudioSegment(part: 77, surah: 43, startAyah: 1, endAyah: null, title: 'Part 77 | Surah Az-Zukhruf', url: '${_tanzeemBase}075-Surah-Zukruf.mp3'),

    // --- SURAH AD-DUKHAN (44) ---
    TafseerAudioSegment(part: 78, surah: 44, startAyah: 1, endAyah: null, title: 'Part 78 | Surah Ad-Dukhan', url: '${_tanzeemBase}076-Surah-Dukhan.mp3'),

    // --- SURAH AL-JATHIYAH (45) ---
    TafseerAudioSegment(part: 79, surah: 45, startAyah: 1, endAyah: null, title: 'Part 79 | Surah Al-Jathiyah', url: '${_tanzeemBase}077-Surah-Jasia.mp3'),

    // --- SURAH AL-AHQAF (46) ---
    TafseerAudioSegment(part: 80, surah: 46, startAyah: 1, endAyah: null, title: 'Part 80 | Surah Al-Ahqaf', url: '${_tanzeemBase}078-Surah-Ahkaf.mp3'),

    // --- SURAH MUHAMMAD (47) ---
    TafseerAudioSegment(part: 81, surah: 47, startAyah: 1, endAyah: null, title: 'Part 81 | Surah Muhammad', url: '${_tanzeemBase}079-Surah-Muhammad.mp3'),

    // --- SURAH AL-FATH (48) ---
    TafseerAudioSegment(part: 82, surah: 48, startAyah: 1, endAyah: null, title: 'Part 82 | Surah Al-Fath', url: '${_tanzeemBase}080-Surah-Fath.mp3'),

    // --- SURAH AL-HUJURAT (49) ---
    TafseerAudioSegment(part: 83, surah: 49, startAyah: 1, endAyah: null, title: 'Part 83 | Surah Al-Hujurat', url: '${_tanzeemBase}081-Surah-Hujurat.mp3'),

    // --- SURAH QAAF (50) ---
    TafseerAudioSegment(part: 84, surah: 50, startAyah: 1, endAyah: null, title: 'Part 84 | Surah Qaaf', url: '${_tanzeemBase}082-Surah-Qaaf.mp3'),

    // --- SURAH AZ-ZARIYAT (51) ---
    TafseerAudioSegment(part: 85, surah: 51, startAyah: 1, endAyah: null, title: 'Part 85 | Surah Az-Zariyat', url: '${_tanzeemBase}083-Surah-Zareaat.mp3'),

    // --- SURAH AT-TOOR (52) ---
    TafseerAudioSegment(part: 86, surah: 52, startAyah: 1, endAyah: null, title: 'Part 86 | Surah At-Toor', url: '${_tanzeemBase}084-Surah-Toor.mp3'),

    // --- SURAH AN-NAJM (53) ---
    TafseerAudioSegment(part: 87, surah: 53, startAyah: 1, endAyah: null, title: 'Part 87 | Surah An-Najm', url: '${_tanzeemBase}085-Surah-An-Najm.mp3'),

    // --- SURAH AL-QAMAR (54) ---
    TafseerAudioSegment(part: 88, surah: 54, startAyah: 1, endAyah: null, title: 'Part 88 | Surah Al-Qamar', url: '${_tanzeemBase}086-Surah-Qmr.mp3'),

    // --- SURAH AR-REHMAN (55) ---
    TafseerAudioSegment(part: 89, surah: 55, startAyah: 1, endAyah: null, title: 'Part 89 | Surah Ar-Rehman', url: '${_tanzeemBase}087-Surah-Rehman.mp3'),

    // --- SURAH AL-WAQIAH (56) ---
    TafseerAudioSegment(part: 90, surah: 56, startAyah: 1, endAyah: null, title: 'Part 90 | Surah Al-Waqiah', url: '${_tanzeemBase}088-Surah-Waqiah.mp3'),

    // --- SURAH AL-HADEED (57) ---
    TafseerAudioSegment(part: 91, surah: 57, startAyah: 1, endAyah: null, title: 'Part 91 | Surah Al-Hadeed', url: '${_tanzeemBase}089-Surah-Hadeed.mp3'),

    // --- SURAH AL-MUJADILAH (58) ---
    TafseerAudioSegment(part: 92, surah: 58, startAyah: 1, endAyah: null, title: 'Part 92 | Surah Al-Mujadilah', url: '${_tanzeemBase}090-Surah-Mujadilah.mp3'),

    // --- SURAH AL-HASHR (59) ---
    TafseerAudioSegment(part: 93, surah: 59, startAyah: 1, endAyah: null, title: 'Part 93 | Surah Al-Hashr', url: '${_tanzeemBase}091-Surah-Hashr.mp3'),

    // --- SURAH AL-MUMTAHINAH (60) ---
    TafseerAudioSegment(part: 94, surah: 60, startAyah: 1, endAyah: null, title: 'Part 94 | Surah Al-Mumtahinah', url: '${_tanzeemBase}092-Surah-Mumtahenah.mp3'),

    // --- SURAH AS-SAFF (61) ---
    TafseerAudioSegment(part: 95, surah: 61, startAyah: 1, endAyah: null, title: 'Part 95 | Surah As-Saff', url: '${_tanzeemBase}093-Surah-Saff.mp3'),

    // --- SURAH AL-JUMUAH (62) ---
    TafseerAudioSegment(part: 96, surah: 62, startAyah: 1, endAyah: null, title: 'Part 96 | Surah Al-Jumuah', url: '${_tanzeemBase}094-Surah-Jumah.mp3'),

    // --- SURAH AL-MUNAFIQUN (63) ---
    TafseerAudioSegment(part: 97, surah: 63, startAyah: 1, endAyah: null, title: 'Part 97 | Surah Al-Munafiqoon', url: '${_tanzeemBase}095-Surah-Munafequn.mp3'),

    // --- SURAH AT-TAGHABUN (64) ---
    TafseerAudioSegment(part: 98, surah: 64, startAyah: 1, endAyah: null, title: 'Part 98 | Surah At-Taghabun', url: '${_tanzeemBase}096-Surah-Taghabn.mp3'),

    // --- SURAH AT-TALAQ (65) ---
    TafseerAudioSegment(part: 99, surah: 65, startAyah: 1, endAyah: null, title: 'Part 99 | Surah At-Talaq', url: '${_tanzeemBase}097-Surah-Talaq.mp3'),

    // --- SURAH AT-TAHREEM (66) ---
    TafseerAudioSegment(part: 100, surah: 66, startAyah: 1, endAyah: null, title: 'Part 100 | Surah At-Tahreem', url: '${_tanzeemBase}098-Surah-Tahreem.mp3'),

    // --- SURAH AL-MULK (67) ---
    TafseerAudioSegment(part: 101, surah: 67, startAyah: 1, endAyah: null, title: 'Part 101 | Surah Al-Mulk', url: '${_tanzeemBase}099-Surah-Mulk.mp3'),

    // --- SURAH AL-QALAM (68) ---
    TafseerAudioSegment(part: 102, surah: 68, startAyah: 1, endAyah: null, title: 'Part 102 | Surah Al-Qalam', url: '${_tanzeemBase}100-Surah-Qlam-Surah-Noon.mp3'),

    // --- SURAH AL-HAQQAH (69) ---
    TafseerAudioSegment(part: 103, surah: 69, startAyah: 1, endAyah: null, title: 'Part 103 | Surah Al-Haqqah', url: '${_tanzeemBase}101-Surah-Haaqah.mp3'),

    // --- SURAH AL-MAARIJ (70) ---
    TafseerAudioSegment(part: 104, surah: 70, startAyah: 1, endAyah: null, title: 'Part 104 | Surah Al-Maarij', url: '${_tanzeemBase}102-Surah-Maarij.mp3'),

    // --- SURAH NOOH (71) ---
    TafseerAudioSegment(part: 105, surah: 71, startAyah: 1, endAyah: null, title: 'Part 105 | Surah Nooh', url: '${_tanzeemBase}103-Surah-Nuh.mp3'),

    // --- SURAH AL-JINN (72) ---
    TafseerAudioSegment(part: 106, surah: 72, startAyah: 1, endAyah: null, title: 'Part 106 | Surah Al-Jinn', url: '${_tanzeemBase}104-Surah-Jinn.mp3'),

    // --- SURAH AL-MUZAMMIL (73) ---
    TafseerAudioSegment(part: 107, surah: 73, startAyah: 1, endAyah: null, title: 'Part 107 | Surah Al-Muzammil', url: '${_tanzeemBase}105-Surah-Muzammil.mp3'),

    // --- SURAH AL-MUDDASSIR (74) ---
    TafseerAudioSegment(part: 108, surah: 74, startAyah: 1, endAyah: null, title: 'Part 108 | Surah Al-Muddassir', url: '${_tanzeemBase}106-Surah-Muddassir.mp3'),

    // --- SURAH AL-QIYAMAH (75) ---
    TafseerAudioSegment(part: 109, surah: 75, startAyah: 1, endAyah: null, title: 'Part 109 | Surah Al-Qiyamah', url: '${_tanzeemBase}107-Surah-Qiamah.mp3'),

    // --- SURAH AD-DAHR / AL-INSAN (76) ---
    TafseerAudioSegment(part: 110, surah: 76, startAyah: 1, endAyah: null, title: 'Part 110 | Surah Ad-Dahr', url: '${_tanzeemBase}108-Surah-Dahr.mp3'),

    // --- SURAH AL-MURSALAT (77) ---
    TafseerAudioSegment(part: 111, surah: 77, startAyah: 1, endAyah: null, title: 'Part 111 | Surah Al-Mursalat', url: '${_tanzeemBase}109-Surah-Mursalat.mp3'),

    // --- SURAH AN-NABA (78) ---
    TafseerAudioSegment(part: 112, surah: 78, startAyah: 1, endAyah: null, title: 'Part 112 | Surah An-Naba', url: '${_tanzeemBase}110-Surah-Naba.mp3'),

    // --- SURAH AN-NAZIAT (79) ---
    TafseerAudioSegment(part: 113, surah: 79, startAyah: 1, endAyah: null, title: 'Part 113 | Surah An-Naziat', url: '${_tanzeemBase}111-Surah-Naziaat.mp3'),

    // --- SURAH ABAS (80) ---
    TafseerAudioSegment(part: 114, surah: 80, startAyah: 1, endAyah: null, title: 'Part 114 | Surah Abas', url: '${_tanzeemBase}112-Surah-Abs.mp3'),

    // --- SURAH AT-TAKWEER (81) ---
    TafseerAudioSegment(part: 115, surah: 81, startAyah: 1, endAyah: null, title: 'Part 115 | Surah At-Takweer', url: '${_tanzeemBase}113-Surah-Takwer.mp3'),

    // --- SURAH AL-INFITAR (82) ---
    TafseerAudioSegment(part: 116, surah: 82, startAyah: 1, endAyah: null, title: 'Part 116 | Surah Al-Infitar', url: '${_tanzeemBase}114-Surah-Anfitar.mp3'),

    // --- SURAH AL-MUTAFFIFEEN (83) ---
    TafseerAudioSegment(part: 117, surah: 83, startAyah: 1, endAyah: null, title: 'Part 117 | Surah Al-Mutaffifeen', url: '${_tanzeemBase}115-Surah-Mutaffifeen.mp3'),

    // --- SURAH AL-INSHIQAQ (84) ---
    TafseerAudioSegment(part: 118, surah: 84, startAyah: 1, endAyah: null, title: 'Part 118 | Surah Al-Inshiqaq', url: '${_tanzeemBase}116-Surah-Inshiqaq.mp3'),

    // --- SURAH AL-BURUJ (85) ---
    TafseerAudioSegment(part: 119, surah: 85, startAyah: 1, endAyah: null, title: 'Part 119 | Surah Al-Buruj', url: '${_tanzeemBase}117-Surah-Buruj.mp3'),

    // --- SURAH AT-TARIQ (86) ---
    TafseerAudioSegment(part: 120, surah: 86, startAyah: 1, endAyah: null, title: 'Part 120 | Surah At-Tariq', url: '${_tanzeemBase}118-Surah-Tariq.mp3'),

    // --- SURAH AL-AALA (87) ---
    TafseerAudioSegment(part: 121, surah: 87, startAyah: 1, endAyah: null, title: 'Part 121 | Surah Al-Aala', url: '${_tanzeemBase}119-Surah-Aala.mp3'),

    // --- SURAH AL-GHASHIYAH (88) ---
    TafseerAudioSegment(part: 122, surah: 88, startAyah: 1, endAyah: null, title: 'Part 122 | Surah Al-Ghashiyah', url: '${_tanzeemBase}120-Surah-Ghashia.mp3'),

    // --- SURAH AL-FAJR (89) ---
    TafseerAudioSegment(part: 123, surah: 89, startAyah: 1, endAyah: null, title: 'Part 123 | Surah Al-Fajr', url: '${_tanzeemBase}121-Surah-Fajr.mp3'),

    // --- SURAH AL-BALAD (90) ---
    TafseerAudioSegment(part: 124, surah: 90, startAyah: 1, endAyah: null, title: 'Part 124 | Surah Al-Balad', url: '${_tanzeemBase}122-Surah-Balad.mp3'),

    // --- SURAH ASH-SHAMS (91) ---
    TafseerAudioSegment(part: 125, surah: 91, startAyah: 1, endAyah: null, title: 'Part 125 | Surah Ash-Shams', url: '${_tanzeemBase}123-Surah-Shams.mp3'),

    // --- SURAH AL-LAIL (92) ---
    TafseerAudioSegment(part: 126, surah: 92, startAyah: 1, endAyah: null, title: 'Part 126 | Surah Al-Lail', url: '${_tanzeemBase}124-Surah-Laiyel.mp3'),

    // --- SURAH AD-DUHA (93) ---
    TafseerAudioSegment(part: 127, surah: 93, startAyah: 1, endAyah: null, title: 'Part 127 | Surah Ad-Duha', url: '${_tanzeemBase}125-Surah-Zuha.mp3'),

    // --- SURAH AL-INSHIRAH / ALAM NASHRAH (94) ---
    TafseerAudioSegment(part: 128, surah: 94, startAyah: 1, endAyah: null, title: 'Part 128 | Surah Al-Inshirah', url: '${_tanzeemBase}126-Surah-Alam-Nashrah.mp3'),

    // --- SURAH AT-TEEN (95) ---
    TafseerAudioSegment(part: 129, surah: 95, startAyah: 1, endAyah: null, title: 'Part 129 | Surah At-Teen', url: '${_tanzeemBase}127-Surah-Teen.mp3'),

    // --- SURAH AL-ALAQ (96) ---
    TafseerAudioSegment(part: 130, surah: 96, startAyah: 1, endAyah: null, title: 'Part 130 | Surah Al-Alaq', url: '${_tanzeemBase}128-Surah-Alaq.mp3'),

    // --- SURAH AL-QADR (97) ---
    TafseerAudioSegment(part: 131, surah: 97, startAyah: 1, endAyah: null, title: 'Part 131 | Surah Al-Qadr', url: '${_tanzeemBase}129-Surah-Qdr.mp3'),

    // --- SURAH AL-BAYYINAH (98) ---
    TafseerAudioSegment(part: 132, surah: 98, startAyah: 1, endAyah: null, title: 'Part 132 | Surah Al-Bayyinah', url: '${_tanzeemBase}130-Surah-Bayenah.mp3'),

    // --- SURAH AZ-ZILZAL (99) ---
    TafseerAudioSegment(part: 133, surah: 99, startAyah: 1, endAyah: null, title: 'Part 133 | Surah Az-Zilzal', url: '${_tanzeemBase}131-Surah-Zilzal.mp3'),

    // --- SURAH AL-ADIYAT (100) ---
    TafseerAudioSegment(part: 134, surah: 100, startAyah: 1, endAyah: null, title: 'Part 134 | Surah Al-Adiyat', url: '${_tanzeemBase}132-Surah-Aadiad.mp3'),

    // --- SURAH AL-QARIAH (101) ---
    TafseerAudioSegment(part: 135, surah: 101, startAyah: 1, endAyah: null, title: 'Part 135 | Surah Al-Qariah', url: '${_tanzeemBase}133-Surah-Qariah.mp3'),

    // --- SURAH AT-TAKASUR (102) ---
    TafseerAudioSegment(part: 136, surah: 102, startAyah: 1, endAyah: null, title: 'Part 136 | Surah At-Takasur', url: '${_tanzeemBase}134-Surah-Takasur.mp3'),

    // --- SURAH AL-ASR (103) ---
    TafseerAudioSegment(part: 137, surah: 103, startAyah: 1, endAyah: null, title: 'Part 137 | Surah Al-Asr', url: '${_tanzeemBase}135-Surah-Asr.mp3'),

    // --- SURAH AL-HUMAZAH (104) ---
    TafseerAudioSegment(part: 138, surah: 104, startAyah: 1, endAyah: null, title: 'Part 138 | Surah Al-Humazah', url: '${_tanzeemBase}136-Surah-Humazah.mp3'),

    // --- SURAH AL-FEEL (105) ---
    TafseerAudioSegment(part: 139, surah: 105, startAyah: 1, endAyah: null, title: 'Part 139 | Surah Al-Feel', url: '${_tanzeemBase}137-Surah-Feel.mp3'),

    // --- SURAH QURAISH (106) ---
    TafseerAudioSegment(part: 140, surah: 106, startAyah: 1, endAyah: null, title: 'Part 140 | Surah Quraish', url: '${_tanzeemBase}138-Surah-Quraish.mp3'),

    // --- SURAH AL-MAOON (107) ---
    TafseerAudioSegment(part: 141, surah: 107, startAyah: 1, endAyah: null, title: 'Part 141 | Surah Al-Maoon', url: '${_tanzeemBase}139-Surah-Maaoun.mp3'),

    // --- SURAH AL-KAUSAR (108) ---
    TafseerAudioSegment(part: 142, surah: 108, startAyah: 1, endAyah: null, title: 'Part 142 | Surah Al-Kausar', url: '${_tanzeemBase}140-Surah-Kusar.mp3'),

    // --- SURAH AL-KAFIROON (109) ---
    TafseerAudioSegment(part: 143, surah: 109, startAyah: 1, endAyah: null, title: 'Part 143 | Surah Al-Kafiroon', url: '${_tanzeemBase}141-Surah-Kaferun.mp3'),

    // --- SURAH AN-NASR (110) ---
    TafseerAudioSegment(part: 144, surah: 110, startAyah: 1, endAyah: null, title: 'Part 144 | Surah An-Nasr', url: '${_tanzeemBase}142-Surah-Nasr.mp3'),

    // --- SURAH AL-LAHAB / MASAD (111) ---
    TafseerAudioSegment(part: 145, surah: 111, startAyah: 1, endAyah: null, title: 'Part 145 | Surah Al-Lahab', url: '${_tanzeemBase}143-Surah-Lahb.mp3'),

    // --- SURAH AL-IKHLAS (112) ---
    TafseerAudioSegment(part: 146, surah: 112, startAyah: 1, endAyah: null, title: 'Part 146 | Surah Al-Ikhlas', url: '${_tanzeemBase}144-Surah-Ikhlas.mp3'),

    // --- SURAH AL-FALAQ (113) ---
    TafseerAudioSegment(part: 147, surah: 113, startAyah: 1, endAyah: null, title: 'Part 147 | Surah Al-Falaq', url: '${_tanzeemBase}145-Surah-Falaq.mp3'),

    // --- SURAH AN-NAAS (114) ---
    TafseerAudioSegment(part: 148, surah: 114, startAyah: 1, endAyah: null, title: 'Part 148 | Surah An-Naas', url: '${_tanzeemBase}146-Surah-Nass.mp3'),

    // --- ENDING SPEECH (Extra) ---
    TafseerAudioSegment(part: 149, surah: 0, startAyah: 1, endAyah: null, title: 'Part 149 | Ending Speech', url: '${_tanzeemBase}147-Ending-speech.mp3'),
  ];

  static final Map<int, List<TafseerAudioSegment>> _tanzeemSurahMap = () {
    final map = <int, List<TafseerAudioSegment>>{};
    for (final seg in _tanzeemSegments) {
      if (!map.containsKey(seg.surah)) {
        map[seg.surah] = [];
      }
      map[seg.surah]!.add(seg);
    }
    return map;
  }();

  // ═══════════════════════════════════════════════════
  // TAFSEER-E-USMANI — Mufti Taqi Usmani (Audio)
  // ═══════════════════════════════════════════════════
  static const List<TafseerAudioSegment> _taqiUsmaniSegments = [
    // --- SURAH AL-FATIHAH (1) ---
    // Note: Bismillah is Ayah 1. Mufti Sb refers to 'Alhamdulillah...' as Ayat 1.
    TafseerAudioSegment(part: 1, surah: 1, startAyah: 1, endAyah: 1, title: 'Wahy ka Taaruf (Intro)', url: 'https://archive.org/download/surah-fatiha-tafseer-mufti-muhammad-taqi-usmani/%2801%29DQ-Wahy_ka_Taaruf%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 2, surah: 1, startAyah: 1, endAyah: 1, title: 'Wahy Nuzool ki Tafseel', url: 'https://archive.org/download/surah-fatiha-tafseer-mufti-muhammad-taqi-usmani/%2802%29DQ-Wahy_aur_us_ke_Nuzool_ki_Tafseel%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 3, surah: 1, startAyah: 1, endAyah: 1, title: 'Quran ko Jama karna', url: 'https://archive.org/download/surah-fatiha-tafseer-mufti-muhammad-taqi-usmani/%2803%29DQ-Quran_ko_Jama_karna%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 4, surah: 1, startAyah: 1, endAyah: 1, title: 'Hifazate Quran', url: 'https://archive.org/download/surah-fatiha-tafseer-mufti-muhammad-taqi-usmani/%2804%29DQ-Hifazate_Quran_aur_Tashrihe_Istilahat%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 5, surah: 1, startAyah: 1, endAyah: 1, title: 'Taawwuz aur Tasmiyah', url: 'https://archive.org/download/surah-fatiha-tafseer-mufti-muhammad-taqi-usmani/%2805%29DQ-S-Fatiha_Taawwuz_aur_Tasmiyah%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 6, surah: 1, startAyah: 1, endAyah: 1, title: 'Falsafa-e-Bismillah', url: 'https://archive.org/download/surah-fatiha-tafseer-mufti-muhammad-taqi-usmani/%2806%29DQ-S-Fatiha_Ahkamam_wa_Falsafae_Bismillah%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 7, surah: 1, startAyah: 2, endAyah: 2, title: 'Ayat 1 (Part 1)', url: 'https://archive.org/download/surah-fatiha-tafseer-mufti-muhammad-taqi-usmani/%2807%29DQ-S-Fatiha_V-01%281%29%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 8, surah: 1, startAyah: 2, endAyah: 2, title: 'Ayat 1 (Part 2)', url: 'https://archive.org/download/surah-fatiha-tafseer-mufti-muhammad-taqi-usmani/%2808%29DQ-S-Fatiha_V-01%282%29%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 9, surah: 1, startAyah: 3, endAyah: 3, title: 'Ayat 2', url: 'https://archive.org/download/surah-fatiha-tafseer-mufti-muhammad-taqi-usmani/%2809%29DQ-S-Fatiha_V-02%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 10, surah: 1, startAyah: 4, endAyah: 4, title: 'Ayat 3 (Part 1)', url: 'https://archive.org/download/surah-fatiha-tafseer-mufti-muhammad-taqi-usmani/%2810%29DQ-S-Fatiha_V-03%281%29%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 11, surah: 1, startAyah: 4, endAyah: 4, title: 'Ayat 3 (Part 2)', url: 'https://archive.org/download/surah-fatiha-tafseer-mufti-muhammad-taqi-usmani/%2811%29DQ-S-Fatiha_V-03%282%29%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 12, surah: 1, startAyah: 5, endAyah: 5, title: 'Ayat 4', url: 'https://archive.org/download/surah-fatiha-tafseer-mufti-muhammad-taqi-usmani/%2812%29DQ-S-Fatiha_V-04%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 13, surah: 1, startAyah: 6, endAyah: 6, title: 'Ayat 5', url: 'https://archive.org/download/surah-fatiha-tafseer-mufti-muhammad-taqi-usmani/%2813%29DQ-S-Fatiha_V-05%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 14, surah: 1, startAyah: 7, endAyah: 7, title: 'Ayat 6-7', url: 'https://archive.org/download/surah-fatiha-tafseer-mufti-muhammad-taqi-usmani/%2814%29DQ-S-Fatiha_V-06-07%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 15, surah: 1, startAyah: 7, endAyah: null, title: 'Dua (Khatima)', url: 'https://archive.org/download/surah-fatiha-tafseer-mufti-muhammad-taqi-usmani/%2815%29DQ-S-Fatiha_Dua%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),

    // --- SURAH AL-BAQARAH (2) ---
    TafseerAudioSegment(part: 1, surah: 2, startAyah: 1, endAyah: 2, title: 'Ayah 1-2', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2801%29Dars-e-Quran%20S-Baqarah-V-001-002%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 2, surah: 2, startAyah: 3, endAyah: 7, title: 'Ayah 3-7', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2802%29Dars-e-Quran%20S-Baqarah-V-003-007%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 3, surah: 2, startAyah: 8, endAyah: 10, title: 'Ayah 8-10', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2803%29Dars-e-Quran%20S-Baqarah-V-008-010%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 4, surah: 2, startAyah: 11, endAyah: 13, title: 'Ayah 11-13', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2804%29Dars-e-Quran%20S-Baqarah-V-011-013%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 5, surah: 2, startAyah: 14, endAyah: 16, title: 'Ayah 14-16', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2805%29Dars-e-Quran%20S-Baqarah-V-014-016%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 6, surah: 2, startAyah: 17, endAyah: 20, title: 'Ayah 17-20', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2806%29Dars-e-Quran%20S-Baqarah-V-017-020%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 7, surah: 2, startAyah: 21, endAyah: 22, title: 'Ayah 21-22', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2807%29Dars-e-Quran%20Surah%20Al-Baqarah-V-021-022%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 8, surah: 2, startAyah: 23, endAyah: 24, title: 'Ayah 23-24', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2808%29Dars-e-Quran%20Surah%20Al-Baqarah-V-023-024%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 9, surah: 2, startAyah: 25, endAyah: 25, title: 'Ayah 25', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2809%29Dars-e-Quran%20S-Baqarah-V-025%28Mufti_Muhammad_Taqi_Usmani.mp3'),
    TafseerAudioSegment(part: 10, surah: 2, startAyah: 26, endAyah: 29, title: 'Ayah 26-29', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2810%29Dars-e-Quran%20S-Baqarah-V-026-029%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 11, surah: 2, startAyah: 30, endAyah: 33, title: 'Ayah 30-33', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2811%29Dars-e-Quran%20S-Baqarah-V-030-033%28Mufti_Muhammad_Taqi_Usmani.mp3'),
    TafseerAudioSegment(part: 12, surah: 2, startAyah: 34, endAyah: 34, title: 'Ayah 34', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2812%29Dars-e-Quran%20S-Baqarah-V-034%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 13, surah: 2, startAyah: 35, endAyah: 35, title: 'Ayah 35', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2813%29Dars-e-Quran%20S-Baqarah-V-035_25-09-1433%28Mufti_Muhammad_Taqi_Usmani%2914-08-2012.mp3'),
    TafseerAudioSegment(part: 14, surah: 2, startAyah: 36, endAyah: 37, title: 'Ayah 36-37', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2814%29Dars-e-Quran%20S-Baqarah-V-036-037%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 15, surah: 2, startAyah: 38, endAyah: 39, title: 'Ayah 38-39', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2815%29Dars-e-Quran%20S-Baqarah-V-038-039%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 16, surah: 2, startAyah: 40, endAyah: 46, title: 'Ayah 40-46', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2816%29Dars-e-Quran%20S-Baqarah-V-040-046%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 17, surah: 2, startAyah: 47, endAyah: 48, title: 'Ayah 47-48', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2817%29Dars-e-Quran%20S-Baqarah-V-047-048%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 18, surah: 2, startAyah: 49, endAyah: 49, title: 'Ayah 49', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2818%29Dars-e-Quran%20S-Baqarah-V-049%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 19, surah: 2, startAyah: 50, endAyah: 53, title: 'Ayah 50-53', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2819%29Dars-e-Quran%20S-Baqarah-V-049-053%28Mufti_Muhammad_Taqi_Usmani%29.mp3'),
    TafseerAudioSegment(part: 20, surah: 2, startAyah: 54, endAyah: 59, title: 'Ayah 54-59', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2820%29Dars-e-Quran%20S-Baqarah-V-054-059_09-11-1433%28Mufti_Muhammad_Taqi_Usmani%2927-10-2012.mp3'),
    TafseerAudioSegment(part: 21, surah: 2, startAyah: 60, endAyah: 66, title: 'Ayah 60-66', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2821%29Dars-e-Quran%20S-Baqarah-V-060-066_10-11-1433%28Mufti_Muhammad_Taqi_Usmani%2928-10-2012.mp3'),
    TafseerAudioSegment(part: 22, surah: 2, startAyah: 67, endAyah: 74, title: 'Ayah 67-74', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2822%29Dars-e-Quran%20S-Baqarah-V-067-074_11-11-1433%28Mufti_Muhammad_Taqi_Usmani%2929-10-2012.mp3'),
    TafseerAudioSegment(part: 23, surah: 2, startAyah: 75, endAyah: 82, title: 'Ayah 75-82', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2823%29Dars-e-Quran%20S-Baqarah-V-075-082_12-11-1433%28Mufti_Muhammad_Taqi_Usmani%2930-10-2012.mp3'),
    TafseerAudioSegment(part: 24, surah: 2, startAyah: 83, endAyah: 93, title: 'Ayah 83-93', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2824%29Dars-e-Quran%20S-Baqarah-V-083-093_13-11-1433%28Mufti_Muhammad_Taqi_Usmani%2931-10-2012.mp3'),
    TafseerAudioSegment(part: 25, surah: 2, startAyah: 94, endAyah: 101, title: 'Ayah 94-101', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2825%29Dars-e-Quran%20S-Baqarah-V-094-101_14-11-1433%28Mufti_Muhammad_Taqi_Usmani%2901-11-2012.mp3'),
    TafseerAudioSegment(part: 26, surah: 2, startAyah: 102, endAyah: 103, title: 'Ayah 102-103', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2826%29Dars-e-Quran%20S-Baqarah-V-102-103_16-11-1433%28Mufti_Muhammad_Taqi_Usmani%2903-11-2012.mp3'),
    TafseerAudioSegment(part: 27, surah: 2, startAyah: 104, endAyah: 104, title: 'Ayah 104', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2827%29Dars-e-Quran%20S-Baqarah-V-104_19-11-1433%28Mufti_Muhammad_Taqi_Usmani%2906-11-2012.mp3'),
    TafseerAudioSegment(part: 28, surah: 2, startAyah: 105, endAyah: 107, title: 'Ayah 105-107', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2828%29Dars-e-Quran%20S-Baqarah-V-105-107_20-11-1434%28Mufti_Muhammad_Taqi_Usmani%2907-11-2012.mp3'),
    TafseerAudioSegment(part: 29, surah: 2, startAyah: 108, endAyah: 109, title: 'Ayah 108-109', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2829%29Dars-e-Quran%20S-Baqarah-V-108-109_13-01-1434%28Mufti_Muhammad_Taqi_Usmani%2928-11-2012.mp3'),
    TafseerAudioSegment(part: 30, surah: 2, startAyah: 110, endAyah: 110, title: 'Ayah 110', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2830%29Dars-e-Quran%20S-Baqarah-V-110_14-01-1434%28Mufti_Muhammad_Taqi_Usmani%2929-11-2012.mp3'),
    TafseerAudioSegment(part: 31, surah: 2, startAyah: 111, endAyah: 113, title: 'Ayah 111-113', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2831%29Dars-e-Quran%20S-Baqarah-V-111-113_16-01-1434%28Mufti_Muhammad_Taqi_Usmani%2901-12-2012.mp3'),
    TafseerAudioSegment(part: 32, surah: 2, startAyah: 114, endAyah: 115, title: 'Ayah 114-115', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2832%29Dars-e-Quran%20S-Baqarah-V-114-115_18-01-1434%28Mufti_Muhammad_Taqi_Usmani%2903-12-2012.mp3'),
    TafseerAudioSegment(part: 33, surah: 2, startAyah: 116, endAyah: 120, title: 'Ayah 116-120', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2833%29Dars-e-Quran%20S-Baqarah-V-116-120_19-01-1434%28Mufti_Muhammad_Taqi_Usmani%2904-12-2012.mp3'),
    TafseerAudioSegment(part: 34, surah: 2, startAyah: 121, endAyah: 123, title: 'Ayah 121-123', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2834%29Dars-e-Quran%20S-Baqarah-V-121-123_04-02-1434%28Mufti_Muhammad_Taqi_Usmani%2919-12-2012.mp3'),
    TafseerAudioSegment(part: 35, surah: 2, startAyah: 124, endAyah: 124, title: 'Ayah 124', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2835%29Dars-e-Quran%20S-Baqarah-V-124_05-02-1434%28Mufti_Muhammad_Taqi_Usmani%2919-12-2012.mp3'),
    TafseerAudioSegment(part: 36, surah: 2, startAyah: 125, endAyah: 126, title: 'Ayah 125-126', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2836%29Dars-e-Quran%20S-Baqarah-V-125-126_07-02-1434%28Mufti_Muhammad_Taqi_Usmani%2922-12-2012.mp3'),
    TafseerAudioSegment(part: 37, surah: 2, startAyah: 127, endAyah: 128, title: 'Ayah 127-128', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2837%29Dars-e-Quran%20S-Baqarah-V-127-128_09-02-1434%28Mufti_Muhammad_Taqi_Usmani%2924-12-2012.mp3'),
    TafseerAudioSegment(part: 38, surah: 2, startAyah: 129, endAyah: 129, title: 'Ayah 129 (Part 1)', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2838%29Dars-e-Quran%20S-Baqarah-V-129%281%29_10-02-1434%28Mufti_Muhammad_Taqi_Usmani%2925-12-2012.mp3'),
    TafseerAudioSegment(part: 39, surah: 2, startAyah: 129, endAyah: 129, title: 'Ayah 129 (Part 2)', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2839%29Dars-e-Quran%20S-Baqarah-V-129%282%29_11-02-1434%28Mufti_Muhammad_Taqi_Usmani%2926-12-2012.mp3'),
    TafseerAudioSegment(part: 40, surah: 2, startAyah: 130, endAyah: 134, title: 'Ayah 130-134', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2840%29Dars-e-Quran%20S-Baqarah-V-130-134_12-02-1434%28Mufti_Muhammad_Taqi_Usmani%2927-12-2012.mp3'),
    TafseerAudioSegment(part: 41, surah: 2, startAyah: 135, endAyah: 141, title: 'Ayah 135-141', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2841%29Dars-e-Quran%20S-Baqarah-V-135-141_14-02-1434%28Mufti_Muhammad_Taqi_Usmani%2929-12-2012.mp3'),
    TafseerAudioSegment(part: 42, surah: 2, startAyah: 142, endAyah: 142, title: 'Ayah 142', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2842%29Dars-e-Quran%20S-Baqarah-V-142_18-02-1434%28Mufti_Muhammad_Taqi_Usmani%2901-01-2013.mp3'),
    TafseerAudioSegment(part: 43, surah: 2, startAyah: 143, endAyah: 143, title: 'Ayah 143 (Part 1)', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2843%29Dars-e-Quran%20S-Baqarah-V-143%281%29_21-02-1434%28Mufti_Muhammad_Taqi_Usmani%2905-01-2013.mp3'),
    TafseerAudioSegment(part: 44, surah: 2, startAyah: 143, endAyah: 143, title: 'Ayah 143 (Part 2)', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2844%29Dars-e-Quran%20S-Baqarah-V-143%282%29_25-02-1434%28Mufti_Muhammad_Taqi_Usmani%2909-01-2013.mp3'),
    TafseerAudioSegment(part: 45, surah: 2, startAyah: 144, endAyah: 150, title: 'Ayah 144-150', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2845%29Dars-e-Quran%20S-Baqarah-V-144-150_26-02-1434%28Mufti_Muhammad_Taqi_Usmani%2910-01-2013.mp3'),
    TafseerAudioSegment(part: 46, surah: 2, startAyah: 151, endAyah: 152, title: 'Ayah 151-152', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2846%29Dars-e-Quran%20S-Baqarah-V-151-152_23-02-1434%28Mufti_Muhammad_Taqi_Usmani%2915-01-2013.mp3'),
    TafseerAudioSegment(part: 47, surah: 2, startAyah: 153, endAyah: 153, title: 'Ayah 153', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2847%29Dars-e-Quran%20S-Baqarah-V-153_06-03-1434%28Mufti_Muhammad_Taqi_Usmani%2919-01-2013.mp3'),
    TafseerAudioSegment(part: 48, surah: 2, startAyah: 154, endAyah: 157, title: 'Ayah 154-157', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2848%29Dars-e-Quran%20S-Baqarah-V-154-157_06-03-1434%28Mufti_Muhammad_Taqi_Usmani%2919-01-2013.mp3'),
    TafseerAudioSegment(part: 49, surah: 2, startAyah: 158, endAyah: 162, title: 'Ayah 158-162', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2849%29Dars-e-Quran%20S-Baqarah-V-158-162_06-03-1434%28Mufti_Muhammad_Taqi_Usmani%2919-01-2013.mp3'),
    TafseerAudioSegment(part: 50, surah: 2, startAyah: 163, endAyah: 164, title: 'Ayah 163-164', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2850%29Dars-e-Quran%20S-Baqarah-V-163-164_10-03-1434%28Mufti_Muhammad_Taqi_Usmani%2923-01-2013.mp3'),
    TafseerAudioSegment(part: 51, surah: 2, startAyah: 165, endAyah: 167, title: 'Ayah 165-167', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2851%29Dars-e-Quran%20S-Baqarah-V-165-167_11-03-1434%28Mufti_Muhammad_Taqi_Usmani%2924-01-2013.mp3'),
    TafseerAudioSegment(part: 52, surah: 2, startAyah: 168, endAyah: 170, title: 'Ayah 168-170', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2852%29Dars-e-Quran%20S-Baqarah-V-168-170_13-03-1434%28Mufti_Muhammad_Taqi_Usmani%2926-01-2013.mp3'),
    TafseerAudioSegment(part: 53, surah: 2, startAyah: 171, endAyah: 173, title: 'Ayah 171-173', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2853%29Dars-e-Quran%20S-Baqarah-V-171-173_16-03-1434%28Mufti_Muhammad_Taqi_Usmani%2929-01-2013.mp3'),
    TafseerAudioSegment(part: 54, surah: 2, startAyah: 174, endAyah: 176, title: 'Ayah 174-176', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2854%29Dars-e-Quran%20S-Baqarah-V-174-176_20-03-1434%28Mufti_Muhammad_Taqi_Usmani%2902-02-2013.mp3'),
    TafseerAudioSegment(part: 55, surah: 2, startAyah: 177, endAyah: 177, title: 'Ayah 177', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2855%29Dars-e-Quran%20S-Baqarah-V-177_22-03-1434%28Mufti_Muhammad_Taqi_Usmani%2904-02-2013.mp3'),
    TafseerAudioSegment(part: 56, surah: 2, startAyah: 178, endAyah: 179, title: 'Ayah 178-179', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2856%29Dars-e-Quran%20S-Baqarah-V-178-179_23-03-1434%28Mufti_Muhammad_Taqi_Usmani%2905-02-2013.mp3'),
    TafseerAudioSegment(part: 57, surah: 2, startAyah: 180, endAyah: 182, title: 'Ayah 180-182', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2857%29Dars-e-Quran%20S-Baqarah-V-180-182_24-03-1434%28Mufti_Muhammad_Taqi_Usmani%2906-02-2013.mp3'),
    TafseerAudioSegment(part: 58, surah: 2, startAyah: 183, endAyah: 184, title: 'Ayah 183-184', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2858%29Dars-e-Quran%20S-Baqarah-V-183-184_27-03-1434%28Mufti_Muhammad_Taqi_Usmani%2909-02-2013.mp3'),
    TafseerAudioSegment(part: 59, surah: 2, startAyah: 185, endAyah: 185, title: 'Ayah 185', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2859%29Dars-e-Quran%20S-Baqarah-V-185_28-03-1434%28Mufti_Muhammad_Taqi_Usmani%2910-02-2013.mp3'),
    TafseerAudioSegment(part: 60, surah: 2, startAyah: 186, endAyah: 187, title: 'Ayah 186-187', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2860%29Dars-e-Quran%20S-Baqarah-V-186-187_01-04-1434%28Mufti_Muhammad_Taqi_Usmani%2912-02-2013.mp3'),
    TafseerAudioSegment(part: 61, surah: 2, startAyah: 188, endAyah: 188, title: 'Ayah 188', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2861%29Dars-e-Quran%20S-Baqarah-V-188_02-04-1434%28Mufti_Muhammad_Taqi_Usmani%2913-02-2013.mp3'),
    TafseerAudioSegment(part: 62, surah: 2, startAyah: 189, endAyah: 192, title: 'Ayah 189-192', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2862%29Dars-e-Quran%20S-Baqarah-V-189-192_03-04-1434%28Mufti_Muhammad_Taqi_Usmani%2914-02-2013.mp3'),
    TafseerAudioSegment(part: 63, surah: 2, startAyah: 193, endAyah: 195, title: 'Ayah 193-195', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2863%29Dars-e-Quran%20S-Baqarah-V-193-195_06-04-1434%28Mufti_Muhammad_Taqi_Usmani%2917-02-2013.mp3'),
    TafseerAudioSegment(part: 64, surah: 2, startAyah: 196, endAyah: 196, title: 'Ayah 196', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2864%29Dars-e-Quran%20S-Baqarah-V-196_07-04-1434%28Mufti_Muhammad_Taqi_Usmani%2918-02-2013.mp3'),
    TafseerAudioSegment(part: 65, surah: 2, startAyah: 197, endAyah: 197, title: 'Ayah 197', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2865%29Dars-e-Quran%20S-Baqarah-V-197_08-04-1434%28Mufti_Muhammad_Taqi_Usmani%2919-02-2013.mp3'),
    TafseerAudioSegment(part: 66, surah: 2, startAyah: 198, endAyah: 203, title: 'Ayah 198-203', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2866%29Dars-e-Quran%20S-Baqarah-V-198-203_09-04-1434%28Mufti_Muhammad_Taqi_Usmani%2920-02-2013.mp3'),
    TafseerAudioSegment(part: 67, surah: 2, startAyah: 204, endAyah: 207, title: 'Ayah 204-207', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2867%29Dars-e-Quran%20S-Baqarah-V-204-207_10-04-1434%28Mufti_Muhammad_Taqi_Usmani%2921-02-2013.mp3'),
    TafseerAudioSegment(part: 68, surah: 2, startAyah: 208, endAyah: 208, title: 'Ayah 208', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2868%29Dars-e-Quran%20S-Baqarah-V-208_11-04-1434%28Mufti_Muhammad_Taqi_Usmani%2923-02-2013.mp3'),
    TafseerAudioSegment(part: 69, surah: 2, startAyah: 209, endAyah: 212, title: 'Ayah 209-212', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2869%29Dars-e-Quran%20S-Baqarah-V-209-212_14-04-1434%28Mufti_Muhammad_Taqi_Usmani%2925-02-2013.mp3'),
    TafseerAudioSegment(part: 70, surah: 2, startAyah: 213, endAyah: 214, title: 'Ayah 213-214', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2870%29Dars-e-Quran%20S-Baqarah-V-213-214_16-04-1434%28Mufti_Muhammad_Taqi_Usmani%2927-02-2013.mp3'),
    TafseerAudioSegment(part: 71, surah: 2, startAyah: 215, endAyah: 215, title: 'Ayah 215', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2871%29Dars-e-Quran%20S-Baqarah-V-215_23-04-1434%28Mufti_Muhammad_Taqi_Usmani%2906-03-2013.mp3'),
    TafseerAudioSegment(part: 72, surah: 2, startAyah: 216, endAyah: 218, title: 'Ayah 216-218', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2872%29Dars-e-Quran%20S-Baqarah-V-216-218_24-04-1434%28Mufti_Muhammad_Taqi_Usmani%2907-03-2013.mp3'),
    TafseerAudioSegment(part: 73, surah: 2, startAyah: 219, endAyah: 219, title: 'Ayah 219', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2873%29Dars-e-Quran%20S-Baqarah-V-219_04-09-1434%28Mufti_Muhammad_Taqi_Usmani%2914-07-2013.mp3'),
    TafseerAudioSegment(part: 74, surah: 2, startAyah: 220, endAyah: 221, title: 'Ayah 220-221', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2874%29Dars-e-Quran%20S-Baqarah-V-220-221_05-09-1434%28Mufti_Muhammad_Taqi_Usmani%2915-07-2013.mp3'),
    TafseerAudioSegment(part: 75, surah: 2, startAyah: 222, endAyah: 223, title: 'Ayah 222-223', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2875%29Dars-e-Quran%20S-Baqarah-V-222-223_06-09-1434%28Mufti_Muhammad_Taqi_Usmani%2916-07-2013.mp3'),
    TafseerAudioSegment(part: 76, surah: 2, startAyah: 224, endAyah: 228, title: 'Ayah 224-228', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2876%29Dars-e-Quran%20S-Baqarah-V-224-228_07-09-1434%28Mufti_Muhammad_Taqi_Usmani%2917-07-2013.mp3'),
    TafseerAudioSegment(part: 77, surah: 2, startAyah: 229, endAyah: 231, title: 'Ayah 229-231', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2877%29Dars-e-Quran%20S-Baqarah-V-229-231_08-09-1434%28Mufti_Muhammad_Taqi_Usmani%2918-07-2013.mp3'),
    TafseerAudioSegment(part: 78, surah: 2, startAyah: 232, endAyah: 233, title: 'Ayah 232-233', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2878%29Dars-e-Quran%20S-Baqarah-V-232-233_10-09-1434%28Mufti_Muhammad_Taqi_Usmani%2920-07-2013.mp3'),
    TafseerAudioSegment(part: 79, surah: 2, startAyah: 234, endAyah: 237, title: 'Ayah 234-237', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2879%29Dars-e-Quran%20S-Baqarah-V-234-237_11-09-1434%28Mufti_Muhammad_Taqi_Usmani%2921-07-2013.mp3'),
    TafseerAudioSegment(part: 80, surah: 2, startAyah: 238, endAyah: 242, title: 'Ayah 238-242', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2880%29Dars-e-Quran%20S-Baqarah-V-238-242_12-09-1434%28Mufti_Muhammad_Taqi_Usmani%2922-07-2013.mp3'),
    TafseerAudioSegment(part: 81, surah: 2, startAyah: 243, endAyah: 245, title: 'Ayah 243-245', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2881%29Dars-e-Quran%20S-Baqarah-V-243-245_13-09-1434%28Mufti_Muhammad_Taqi_Usmani%2923-07-2013.mp3'),
    TafseerAudioSegment(part: 82, surah: 2, startAyah: 246, endAyah: 248, title: 'Ayah 246-248', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2882%29Dars-e-Quran%20S-Baqarah-V-246-248_14-09-1434%28Mufti_Muhammad_Taqi_Usmani%2924-07-2013.mp3'),
    TafseerAudioSegment(part: 83, surah: 2, startAyah: 249, endAyah: 252, title: 'Ayah 249-252', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2883%29Dars-e-Quran%20S-Baqarah-V-249-252_15-09-1434%28Mufti_Muhammad_Taqi_Usmani%2925-07-2013.mp3'),
    TafseerAudioSegment(part: 84, surah: 2, startAyah: 253, endAyah: 254, title: 'Ayah 253-254', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2884%29Dars-e-Quran%20S-Baqarah-V-253-254_17-09-1434%28Mufti_Muhammad_Taqi_Usmani%2927-07-2013.mp3'),
    TafseerAudioSegment(part: 85, surah: 2, startAyah: 255, endAyah: 255, title: 'Ayah 255 (Ayatul Kursi)', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2885%29Dars-e-Quran%20S-Baqarah-V-255_18-09-1434%28Mufti_Muhammad_Taqi_Usmani%2928-07-2013.mp3'),
    TafseerAudioSegment(part: 86, surah: 2, startAyah: 256, endAyah: 258, title: 'Ayah 256-258', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2886%29Dars-e-Quran%20S-Baqarah-V-256-258_19-09-1434%28Mufti_Muhammad_Taqi_Usmani%2929-07-2013.mp3'),
    TafseerAudioSegment(part: 87, surah: 2, startAyah: 259, endAyah: 260, title: 'Ayah 259-260', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2887%29Dars-e-Quran%20S-Baqarah-V-259-260_20-09-1434%28Mufti_Muhammad_Taqi_Usmani%2930-07-2013.mp3'),
    TafseerAudioSegment(part: 88, surah: 2, startAyah: 261, endAyah: 266, title: 'Ayah 261-266', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2888%29Dars-e-Quran%20S-Baqarah-V-261-266_21-09-1434%28Mufti_Muhammad_Taqi_Usmani%2931-07-2013.mp3'),
    TafseerAudioSegment(part: 89, surah: 2, startAyah: 267, endAyah: 274, title: 'Ayah 267-274', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2889%29Dars-e-Quran%20S-Baqarah-V-267-274_22-09-1434%28Mufti_Muhammad_Taqi_Usmani%2901-08-2013.mp3'),
    TafseerAudioSegment(part: 90, surah: 2, startAyah: 275, endAyah: 275, title: 'Ayah 275', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2890%29Dars-e-Quran%20S-Baqarah-V-275_24-09-1434%28Mufti_Muhammad_Taqi_Usmani%2903-08-2013.mp3'),
    TafseerAudioSegment(part: 91, surah: 2, startAyah: 276, endAyah: 281, title: 'Ayah 276-281', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2891%29Dars-e-Quran%20S-Baqarah-V-276-281_25-09-1434%28Mufti_Muhammad_Taqi_Usmani%2904-08-2013.mp3'),
    TafseerAudioSegment(part: 92, surah: 2, startAyah: 282, endAyah: 283, title: 'Ayah 282-283', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2892%29Dars-e-Quran%20S-Baqarah-V-282-283_26-09-1434%28Mufti_Muhammad_Taqi_Usmani%2905-08-2013.mp3'),
    TafseerAudioSegment(part: 93, surah: 2, startAyah: 284, endAyah: 286, title: 'Ayah 284-286', url: 'https://archive.org/download/surah-baqarah-tafseer-mufti-taqi-usmani/%2893%29Dars-e-Quran%20S-Baqarah-V-284-286_27-09-1434%28Mufti_Muhammad_Taqi_Usmani%2906-08-2013.mp3'),

    // --- SURAH AL-MAIDAH (5) ---
    TafseerAudioSegment(part: 1, surah: 5, startAyah: 1, endAyah: 1, title: 'Ayah 1', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2801%29S-Maidah-V-01_20-09-1440%28Mufti%20Muhammad%20Taqi%20Usmani%2926-05-2019.mp3'),
    TafseerAudioSegment(part: 2, surah: 5, startAyah: 2, endAyah: 2, title: 'Ayah 2 (Part 1)', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2802%29S-Maidah-V-02_21-09-1440%28Mufti%20Muhammad%20Taqi%20Usmani%2927-05-2019.mp3'),
    TafseerAudioSegment(part: 3, surah: 5, startAyah: 2, endAyah: 2, title: 'Ayah 2 (Part 2)', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2803%29S-Maidah-V-02_22-09-1440%28Mufti%20Muhammad%20Taqi%20Usmani%2928-05-2019.mp3'),
    TafseerAudioSegment(part: 4, surah: 5, startAyah: 3, endAyah: 3, title: 'Ayah 3 (Part 1)', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2804%29S-Maidah-V-03_24-09-1440%28Mufti%20Muhammad%20Taqi%20Usmani%2930-05-2019.mp3'),
    TafseerAudioSegment(part: 5, surah: 5, startAyah: 3, endAyah: 3, title: 'Ayah 3 (Part 2)', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2805%29S-Maidah-V-03_26-09-1440%28Mufti%20Muhammad%20Taqi%20Usmani%2901-06-2019.mp3'),
    TafseerAudioSegment(part: 6, surah: 5, startAyah: 4, endAyah: 4, title: 'Ayah 4', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2806%29S-Maidah-V-04_27-09-1440%28Mufti%20Muhammad%20Taqi%20Usmani%2902-06-2019.mp3'),
    TafseerAudioSegment(part: 7, surah: 5, startAyah: 5, endAyah: 5, title: 'Ayah 5', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2807%29S-Maidah-V-05_28-09-1440%28Mufti%20Muhammad%20Taqi%20Usmani%2903-06-2019.mp3'),
    TafseerAudioSegment(part: 8, surah: 5, startAyah: 6, endAyah: 7, title: 'Ayah 6-7', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2808%29S-Maidah-V-06-07_29_09-1440%28Mufti%20Muhammad%20Taqi%20Usmani%2904-06-2019.mp3'),
    TafseerAudioSegment(part: 9, surah: 5, startAyah: 8, endAyah: 10, title: 'Ayah 8-10', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2809%29S-Maidah-V-08-10_04_09-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2928-04-2020.mp3'),
    TafseerAudioSegment(part: 10, surah: 5, startAyah: 11, endAyah: 13, title: 'Ayah 11-13', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2810%29S-Maidah-V-11-13_05_09-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2929-04-2020.mp3'),
    TafseerAudioSegment(part: 11, surah: 5, startAyah: 14, endAyah: 16, title: 'Ayah 14-16', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2811%29S-Maidah-V-14-16_06_09-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2930-04-2020.mp3'),
    TafseerAudioSegment(part: 12, surah: 5, startAyah: 17, endAyah: 19, title: 'Ayah 17-19', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2812%29S-Maidah-V-17-19_08_09-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2902-05-2020.mp3'),
    TafseerAudioSegment(part: 13, surah: 5, startAyah: 20, endAyah: 26, title: 'Ayah 20-26', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2813%29S-Maidah-V-20-26_09_09-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2903-05-2020.mp3'),
    TafseerAudioSegment(part: 14, surah: 5, startAyah: 26, endAyah: 32, title: 'Ayah 26-32', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2814%29S-Maidah-V-26-32_10-09-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2904-05-2020.mp3'),
    TafseerAudioSegment(part: 15, surah: 5, startAyah: 33, endAyah: 37, title: 'Ayah 33-37', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2815%29S-Maidah-V-33-37_11-09-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2905-05-2020.mp3'),
    TafseerAudioSegment(part: 16, surah: 5, startAyah: 38, endAyah: 40, title: 'Ayah 38-40', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2816%29S-Maidah-V-38-40_12-09-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2906-05-2020.mp3'),
    TafseerAudioSegment(part: 17, surah: 5, startAyah: 41, endAyah: 43, title: 'Ayah 41-43', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2817%29S-Maidah-V-41-43_13-09-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2907-05-2020.mp3'),
    TafseerAudioSegment(part: 18, surah: 5, startAyah: 44, endAyah: 50, title: 'Ayah 44-50', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2818%29S-Maidah-V-44-50_16-09-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2910-05-2020.mp3'),
    TafseerAudioSegment(part: 19, surah: 5, startAyah: 51, endAyah: 58, title: 'Ayah 51-58', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2819%29S-Maidah-V-51-58_17-09-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2911-05-2020.mp3'),
    TafseerAudioSegment(part: 20, surah: 5, startAyah: 59, endAyah: 62, title: 'Ayah 59-62', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2820%29S-Maidah-V-59-62_18-09-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2912-05-2020.mp3'),
    TafseerAudioSegment(part: 21, surah: 5, startAyah: 63, endAyah: 63, title: 'Ayah 63', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2821%29S-Maidah-V-63_19-09-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2913-05-2020.mp3'),
    TafseerAudioSegment(part: 22, surah: 5, startAyah: 64, endAyah: 67, title: 'Ayah 64-67', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2822%29S-Maidah-V-64-67_20-09-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2914-05-2020.mp3'),
    TafseerAudioSegment(part: 23, surah: 5, startAyah: 68, endAyah: 71, title: 'Ayah 68-71', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2823%29S-Maidah-V-68-71_22-09-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2916-05-2020.mp3'),
    TafseerAudioSegment(part: 24, surah: 5, startAyah: 72, endAyah: 77, title: 'Ayah 72-77', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2824%29S-Maidah-V-72-77_23-09-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2917-05-2020.mp3'),
    TafseerAudioSegment(part: 25, surah: 5, startAyah: 78, endAyah: 86, title: 'Ayah 78-86', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2825%29S-Maidah-V-78-86_24-09-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2918-05-2020.mp3'),
    TafseerAudioSegment(part: 26, surah: 5, startAyah: 87, endAyah: 88, title: 'Ayah 87-88', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2826%29S-Maidah-V-87-88_25-09-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2919-05-2020.mp3'),
    TafseerAudioSegment(part: 27, surah: 5, startAyah: 89, endAyah: 89, title: 'Ayah 89', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2827%29S-Maidah-V-89_26-09-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2920-05-2020.mp3'),
    TafseerAudioSegment(part: 28, surah: 5, startAyah: 90, endAyah: 93, title: 'Ayah 90-93', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2828%29S-Maidah-V-90-93_27-09-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2921-05-2020.mp3'),
    TafseerAudioSegment(part: 29, surah: 5, startAyah: 94, endAyah: 96, title: 'Ayah 94-96', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2829%29S-Maidah-V-94-96_23-10-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2915-06-2020.mp3'),
    TafseerAudioSegment(part: 30, surah: 5, startAyah: 97, endAyah: 100, title: 'Ayah 97-100', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2830%29S-Maidah-V-97-100_24-10-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2916-06-2020.mp3'),
    TafseerAudioSegment(part: 31, surah: 5, startAyah: 101, endAyah: 103, title: 'Ayah 101-103', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2831%29S-Maidah-V-101-103_25-10-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2917-06-2020.mp3'),
    TafseerAudioSegment(part: 32, surah: 5, startAyah: 104, endAyah: 105, title: 'Ayah 104-105', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2832%29S-Maidah-V-104-105_26-10-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2918-06-2020.mp3'),
    TafseerAudioSegment(part: 33, surah: 5, startAyah: 106, endAyah: 108, title: 'Ayah 106-108', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2833%29S-Maidah-V-106-108_28-10-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2920-06-2020.mp3'),
    TafseerAudioSegment(part: 34, surah: 5, startAyah: 108, endAyah: 110, title: 'Ayah 108-110', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2834%29S-Maidah-V-108-110_29-10-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2921-06-2020.mp3'),
    TafseerAudioSegment(part: 35, surah: 5, startAyah: 111, endAyah: 120, title: 'Ayah 111-120', url: 'https://archive.org/download/surah-maidah-tafseer-mufti-taqi-usmani/%2835%29S-Maidah-V-111-120_30-10-1441%28Mufti%20Muhammad%20Taqi%20Usmani%2922-06-2020.mp3'),

    // --- SURAH AL-A'RAF (7) ---
    TafseerAudioSegment(part: 1, surah: 7, startAyah: 1, endAyah: 10, title: 'Ayah 1-10', url: 'https://archive.org/download/surah-araf-tafseer-mufti-taqi-usmani/%2801%29S-Araf-V-01-10_09-09-1442%28Mufti%20Muhammad%20Taqi%20Usmani%2922-04-2021.mp3'),
    TafseerAudioSegment(part: 2, surah: 7, startAyah: 11, endAyah: 18, title: 'Ayah 11-18', url: 'https://archive.org/download/surah-araf-tafseer-mufti-taqi-usmani/%2802%29S-Araf-V-11-18_11-09-1442%28Mufti%20Muhammad%20Taqi%20Usmani%2924-04-2021.mp3'),
    TafseerAudioSegment(part: 3, surah: 7, startAyah: 19, endAyah: 25, title: 'Ayah 19-25', url: 'https://archive.org/download/surah-araf-tafseer-mufti-taqi-usmani/%2803%29S-Araf-V-19-25_13-09-1442%28Mufti%20Muhammad%20Taqi%20Usmani%2926-04-2021.mp3'),
    TafseerAudioSegment(part: 4, surah: 7, startAyah: 26, endAyah: 28, title: 'Ayah 26-28', url: 'https://archive.org/download/surah-araf-tafseer-mufti-taqi-usmani/%2804%29S-Araf-V-26-28_14-09-1442%28Mufti%20Muhammad%20Taqi%20Usmani%2927-04-2021.mp3'),
    TafseerAudioSegment(part: 5, surah: 7, startAyah: 29, endAyah: 32, title: 'Ayah 29-32', url: 'https://archive.org/download/surah-araf-tafseer-mufti-taqi-usmani/%2805%29S-Araf-V-29-32_15-09-1442%28Mufti%20Muhammad%20Taqi%20Usmani%2928-05-2021.mp3'),
    TafseerAudioSegment(part: 6, surah: 7, startAyah: 33, endAyah: 41, title: 'Ayah 33-41', url: 'https://archive.org/download/surah-araf-tafseer-mufti-taqi-usmani/%2806%29S-Araf-V-33-41_16-09-1442%28Mufti%20Muhammad%20Taqi%20Usmani%2929-04-2021.mp3'),
    TafseerAudioSegment(part: 7, surah: 7, startAyah: 42, endAyah: 47, title: 'Ayah 42-47', url: 'https://archive.org/download/surah-araf-tafseer-mufti-taqi-usmani/%2807%29S-Araf-V-42-47_18-09-1442%28Mufti%20Muhammad%20Taqi%20Usmani%2901-05-2021.mp3'),
    TafseerAudioSegment(part: 8, surah: 7, startAyah: 48, endAyah: 53, title: 'Ayah 48-53', url: 'https://archive.org/download/surah-araf-tafseer-mufti-taqi-usmani/%2808%29S-Araf-V-48-53_20-09-1442%28Mufti%20Muhammad%20Taqi%20Usmani%2903-05-2021.mp3'),
    TafseerAudioSegment(part: 9, surah: 7, startAyah: 54, endAyah: 54, title: 'Ayah 54', url: 'https://archive.org/download/surah-araf-tafseer-mufti-taqi-usmani/%2809%29S-Araf-V-54_21-09-1442%28Mufti%20Muhammad%20Taqi%20Usmani%2904-05-2021.mp3'),
    TafseerAudioSegment(part: 10, surah: 7, startAyah: 55, endAyah: 56, title: 'Ayah 55-56', url: 'https://archive.org/download/surah-araf-tafseer-mufti-taqi-usmani/%2810%29S-Araf-V-55-56_22-09-1442%28Mufti%20Muhammad%20Taqi%20Usmani%2905-05-2021.mp3'),
    TafseerAudioSegment(part: 11, surah: 7, startAyah: 57, endAyah: 58, title: 'Ayah 57-58', url: 'https://archive.org/download/surah-araf-tafseer-mufti-taqi-usmani/%2811%29S-Araf-V-57-58_26-09-1442%28Mufti%20Muhammad%20Taqi%20Usmani%2909-05-2021.mp3'),
    TafseerAudioSegment(part: 12, surah: 7, startAyah: 59, endAyah: 64, title: 'Ayah 59-64', url: 'https://archive.org/download/surah-araf-tafseer-mufti-taqi-usmani/%2812%29S-Araf-V-59-64_27-09-1442%28Mufti%20Muhammad%20Taqi%20Usmani%2910-05-2021.mp3'),
    TafseerAudioSegment(part: 13, surah: 7, startAyah: 65, endAyah: 72, title: 'Ayah 65-72', url: 'https://archive.org/download/surah-araf-tafseer-mufti-taqi-usmani/%2813%29S-Araf-V-65-72_28-09-1442%28Mufti%20Muhammad%20Taqi%20Usmani%2911-05-2021.mp3'),
    TafseerAudioSegment(part: 14, surah: 7, startAyah: 73, endAyah: 79, title: 'Ayah 73-79', url: 'https://archive.org/download/surah-araf-tafseer-mufti-taqi-usmani/%2814%29S-Araf-V-73-79_05-10-1442%28Mufti%20Muhammad%20Taqi%20Usmani%2917-05-2021.mp3'),
    TafseerAudioSegment(part: 15, surah: 7, startAyah: 80, endAyah: 84, title: 'Ayah 80-84', url: 'https://archive.org/download/surah-araf-tafseer-mufti-taqi-usmani/%2815%29S-Araf-V-80-84_07-10-1442%28Mufti%20Muhammad%20Taqi%20Usmani%2919-05-2021.mp3'),
    TafseerAudioSegment(part: 16, surah: 7, startAyah: 85, endAyah: 93, title: 'Ayah 85-93', url: 'https://archive.org/download/surah-araf-tafseer-mufti-taqi-usmani/%2816%29S-Araf-V-85-93_08-10-1442%28Mufti%20Muhammad%20Taqi%20Usmani%2920-05-2021.mp3'),
    TafseerAudioSegment(part: 17, surah: 7, startAyah: 94, endAyah: 102, title: 'Ayah 94-102', url: 'https://archive.org/download/surah-araf-tafseer-mufti-taqi-usmani/%2817%29S-Araf-V-94-102_13-10-1442%28Mufti%20Muhammad%20Taqi%20Usmani%2925-05-2021.mp3'),

    // --- SURAH AL-MUTAFFIFEEN (83) ---
    TafseerAudioSegment(part: 1, surah: 83, startAyah: 1, endAyah: 36, title: 'Full Surah', url: 'https://www.nooresunnat.com/Audio/Baitul%20Mukarram/Mufti%20Taqi%20Usmani/Surah%20Mutaffifeen/Tafseer%20Surah%20Mutaffifeen%20-%20I%20(Naap%20Tol%20Main%20Kami%20Ka%20Gunah%20Aur%20Uska%20Wasee%20Mafhum).MP3'),

    // --- SURAH AL-INSHIQAQ (84) ---
    TafseerAudioSegment(part: 1, surah: 84, startAyah: 1, endAyah: 25, title: 'Full Surah', url: 'https://www.nooresunnat.com/Audio/Baitul%20Mukarram/Mufti%20Taqi%20Usmani/Surah%20Inshiqaq/Tafseer%20Surah%20Inshiqaq%20-%20IX%20(Surah%20Ka%20Khulasa%20Aur%20Sabaq).MP3'),

    // --- SURAH AL-ALA (87) ---
    TafseerAudioSegment(part: 1, surah: 87, startAyah: 1, endAyah: 19, title: 'Full Surah', url: 'https://www.nooresunnat.com/Audio/Baitul%20Mukarram/Mufti%20Taqi%20Usmani/Tafseer%20Surah%20Al-Ala/Tafseer%20Surah%20Al-Ala%20-%20II%20(Allah%20Taala%20Ne%20Har%20Cheez%20Ko%20Uske%20Maqsad%20e%20Hayat%20Ki%20Hidayat%20Farma%20Di%20Hai).mp3'),

    // --- SURAH AL-FAJR (89) ---
    TafseerAudioSegment(part: 1, surah: 89, startAyah: 1, endAyah: 30, title: 'Full Surah', url: 'https://www.nooresunnat.com/Audio/Baitul%20Mukarram/Mufti%20Taqi%20Usmani/Tafseer%20Surah%20Fajr/Tafseer%20Surah%20Fajr%20-%20IV%20(Qom%20e%20Aad%20Par%20Dardnaak%20Azab%20Aur%20Hamare%20Liye%20Sabaq).mp3'),

    // --- SURAH ASH-SHAMS (91) ---
    TafseerAudioSegment(part: 1, surah: 91, startAyah: 1, endAyah: 15, title: 'Full Surah', url: 'https://www.nooresunnat.com/Audio/Baitul%20Mukarram/Mufti%20Taqi%20Usmani/Tafseer%20Surah%20Shams/Tafseer%20Surah%20Shams%20-%20I%20(Suraj%20Aur%20Chand%20Ka%20Nizaam,%20Kamyab%20Logo%20Ki%20Pehchan).mp3'),

    // --- SURAH AL-INSHIRAH (94) ---
    TafseerAudioSegment(part: 1, surah: 94, startAyah: 1, endAyah: 4, title: 'Ayah 1-4', url: 'https://www.nooresunnat.com/Audio/Baitul%20Mukarram/Mufti%20Taqi%20Usmani/Tafseer%20Surah%20Inshirah/Tafseer%20Surah%20Alam%20Nashrah%20-%20I%20(Mansab%20e%20Nabuwwat%20Ki%20Azeem%20Zimmedaariya%20-%20Nabi%20SAW%20Ka%20Seena%20Khul%20Jana).mp3'),
    TafseerAudioSegment(part: 2, surah: 94, startAyah: 5, endAyah: 8, title: 'Ayah 5-8', url: 'https://www.nooresunnat.com/Audio/Baitul%20Mukarram/Mufti%20Taqi%20Usmani/Tafseer%20Surah%20Inshirah/Tafseer%20Surah%20Inshirah%20-%20II%20(Har%20Mushkil%20Kay%20Sath%20Do%20Asaania%20Hain).mp3'),

    // --- SURAH AT-TEEN (95) ---
    TafseerAudioSegment(part: 1, surah: 95, startAyah: 1, endAyah: 8, title: 'Full Surah', url: 'https://www.nooresunnat.com/Audio/Baitul%20Mukarram/Mufti%20Taqi%20Usmani/Tafseer%20Surah%20Teen/Tafseer%20Surah%20Teen%20-%20I%20(3%20Cheezo%20Ki%20Qasam,%20Insaan%20Behtreen%20Makhlooq%20Hai).mp3'),

    // --- SURAH AL-ALAQ (96) ---
    TafseerAudioSegment(part: 1, surah: 96, startAyah: 1, endAyah: 19, title: 'Full Surah', url: 'https://www.nooresunnat.com/Audio/Baitul%20Mukarram/Mufti%20Taqi%20Usmani/Tafseer%20Surah%20Alaq/Tafseer%20Surah%20Alaq%20-%20II%20(Pehli%20Wahi%20Ka%20Peghaam).mp3'),
    
    // --- SURAH AT-TAKASUR (102) ---
    TafseerAudioSegment(part: 1, surah: 102, startAyah: 1, endAyah: 8, title: 'Full Surah', url: 'https://www.nooresunnat.com/Audio/Baitul%20Mukarram/Mufti%20Taqi%20Usmani/Tafseer%20Surah%20Takasur/Tafseer%20Surah%20Takasur%20-%20I.mp3'),

    // --- SURAH AL-ASR (103) ---
    TafseerAudioSegment(part: 1, surah: 103, startAyah: 1, endAyah: 3, title: 'Full Surah', url: 'https://www.nooresunnat.com/Audio/Baitul%20Mukarram/Mufti%20Taqi%20Usmani/Tafseer%20Surah%20Asr/Tafseer%20Surah%20Asr%20-%20V(Naseehat%20Kay%20Aadaab).mp3'),

    // --- SURAH AL-HUMAZA (104) ---
    TafseerAudioSegment(part: 1, surah: 104, startAyah: 1, endAyah: 9, title: 'Full Surah', url: 'https://www.nooresunnat.com/Audio/Baitul%20Mukarram/Mufti%20Taqi%20Usmani/Tafseer%20Surah%20Humaza/Tafseer%20Surah%20Humaza%20-%20II%20(Namoos%20e%20Risalat%20-%20Boycott%20Facebook).mp3'),

    // --- SURAH QURAISH (106) ---
    TafseerAudioSegment(part: 1, surah: 106, startAyah: 1, endAyah: 4, title: 'Full Surah', url: 'https://www.nooresunnat.com/Audio/Baitul%20Mukarram/Mufti%20Taqi%20Usmani/Tafseer%20Surah%20Quraish/Tafseer%20Surah%20Quraish%20-%20I%20(Mulk%20Kay%20Mojuda%20Halat).mp3'),

    // --- SURAH AL-KAUSAR (108) ---
    TafseerAudioSegment(part: 1, surah: 108, startAyah: 1, endAyah: 3, title: 'Full Surah', url: 'https://www.nooresunnat.com/Audio/Baitul%20Mukarram/Mufti%20Taqi%20Usmani/Tafseer%20Surah%20Kausar/www.mehboob-e-elahi.com-%20Tafseer%20Surah%20Kausar(Azmat%20e%20Rasoolullah%20SAW).mp3'),

    // --- SURAH AN-NASR (110) ---
    TafseerAudioSegment(part: 1, surah: 110, startAyah: 1, endAyah: 3, title: 'Full Surah', url: 'https://www.nooresunnat.com/Audio/Baitul%20Mukarram/Mufti%20Taqi%20Usmani/Tafseer%20Surah%20Nasr/www.mehboob-e-elahi.com-Tafseer%20Surah%20Nasr-II.mp3'),

    // --- SURAH AL-LAHAB (111) ---
    TafseerAudioSegment(part: 1, surah: 111, startAyah: 1, endAyah: 5, title: 'Full Surah', url: 'https://www.nooresunnat.com/Audio/Baitul%20Mukarram/Mufti%20Taqi%20Usmani/Tafseer%20Surah%20Lahab/www.mehboob-e-elahi.com-Tafseer%20Surah%20Lahab%20-%20II(Maal%20Sukoon%20Ki%20Zamanat%20Nahi).mp3'),

    // --- SURAH AL-FALAQ (113) ---
    TafseerAudioSegment(part: 1, surah: 113, startAyah: 1, endAyah: 5, title: 'Full Surah', url: 'https://www.nooresunnat.com/Audio/Baitul%20Mukarram/Mufti%20Taqi%20Usmani/Tafseer%20Surah%20Falaq-Naas/Tafseer%20Surah%20Falaq/www.mehboob-e-elahi.com-Tafseer%20Surah%20Falaq%20-%201.mp3'),

    // --- SURAH AN-NAS (114) ---
    TafseerAudioSegment(part: 1, surah: 114, startAyah: 1, endAyah: 6, title: 'Full Surah', url: 'https://www.nooresunnat.com/Audio/Baitul%20Mukarram/Mufti%20Taqi%20Usmani/Tafseer%20Surah%20Falaq-Naas/Tafseer%20Surah%20Naas/www.mehboob-e-elahi.com-Tafseer%20Surah%20Naas-3%20(Taaweez%20Gando%20Ka%20Istemaal).mp3'),
  ];

  static final Map<int, List<TafseerAudioSegment>> _taqiUsmaniSurahMap = () {
    final map = <int, List<TafseerAudioSegment>>{};
    for (final seg in _taqiUsmaniSegments) {
      if (!map.containsKey(seg.surah)) {
        map[seg.surah] = [];
      }
      map[seg.surah]!.add(seg);
    }
    return map;
  }();

  TafseerService(this._dio, this._cacheBox);

  /// Fetches Tafseer text for a complete Surah
  /// Returns a Map where Key = Ayah Number, Value = Tafseer Text
  /// If [quranComTafsirId] is provided, fetches from Quran.com Tafsir API.
  /// If [quranComTranslationId] is provided, fetches from Quran.com Translation API.
  /// Otherwise falls back to spa5k API.
  Future<Map<int, String>> getTafseerText(String id, int surahNumber, {int? quranComTafsirId, int? quranComTranslationId}) async {
    final cacheKey = 'tafseer_text_${id}_$surahNumber';
    
    // 1. Check Cache
    final cached = _cacheBox.get(cacheKey);
    if (cached != null) {
      return Map<int, String>.from(cached as Map);
    }

    try {
      Map<int, String> resultMap;

      if (quranComTafsirId != null) {
        // Fetch from Quran.com Tafsir API (ayah-by-ayah)
        resultMap = await _fetchTafseerFromQuranCom(quranComTafsirId, surahNumber);
      } else if (quranComTranslationId != null) {
        // Fetch from Quran.com Translation API (ayah-by-ayah)
        resultMap = await _fetchTranslationFromQuranCom(quranComTranslationId, surahNumber);
      } else {
        // Fetch from legacy spa5k API
        resultMap = await _fetchTafseerFromSpa5k(id, surahNumber);
      }

      // Save to Cache
      if (resultMap.isNotEmpty) {
        await _cacheBox.put(cacheKey, resultMap);
      }
      return resultMap;
    } catch (e) {
      debugPrint('Error fetching Tafseer ($id): $e');
      throw Exception('Failed to load Tafseer');
    }
  }

  /// Fetch tafseer from legacy spa5k API
  Future<Map<int, String>> _fetchTafseerFromSpa5k(String id, int surahNumber) async {
    final url = '$_baseUrl/$id/$surahNumber.json';
    final res = await _dio.get(url);

    if (res.statusCode == 200) {
      final data = res.data;
      final ayahs = data['ayahs'] as List;

      final resultMap = <int, String>{};
      for (final item in ayahs) {
        final ayahNum = item['ayah'] as int;
        final text = item['text'] as String;
        resultMap[ayahNum] = text;
      }
      return resultMap;
    }
    return {};
  }

  /// Fetch tafseer from Quran.com API (ayah-by-ayah for a full surah)
  Future<Map<int, String>> _fetchTafseerFromQuranCom(int tafsirId, int surahNumber) async {
    final resultMap = <int, String>{};

    // Quran.com API: GET /tafsirs/{tafsir_id}/by_chapter/{chapter_number}
    // This endpoint returns all ayahs for the surah at once
    try {
      final res = await _dio.get(
        '$_quranComBase/tafsirs/$tafsirId/by_chapter/$surahNumber',
      );

      if (res.statusCode == 200) {
        final tafsirs = res.data['tafsirs'] as List?;
        if (tafsirs != null) {
          for (final t in tafsirs) {
            final verseKey = t['verse_key'] as String? ?? '';
            final parts = verseKey.split(':');
            final ayahNum = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
            final rawText = t['text'] as String? ?? '';
            // Strip HTML tags for clean display
            final cleanText = rawText.replaceAll(RegExp(r'<[^>]*>'), '').trim();
            if (ayahNum > 0 && cleanText.isNotEmpty) {
              resultMap[ayahNum] = cleanText;
            }
          }
        }
      }
    } catch (e) {
      // Fallback: try per-ayah endpoint (slower but more reliable)
      debugPrint('Chapter-level tafsir fetch failed, trying per-ayah: $e');
      // We don't know total ayahs, so try up to 300 (max in any surah is 286)
      for (int ayah = 1; ayah <= 300; ayah++) {
        try {
          final res = await _dio.get(
            '$_quranComBase/tafsirs/$tafsirId/by_ayah/$surahNumber:$ayah',
          );
          if (res.statusCode == 200) {
            final tafsir = res.data['tafsir'];
            if (tafsir != null) {
              final rawText = tafsir['text'] as String? ?? '';
              final cleanText = rawText.replaceAll(RegExp(r'<[^>]*>'), '').trim();
              if (cleanText.isNotEmpty) {
                resultMap[ayah] = cleanText;
              }
            }
          } else {
            break; // No more ayahs
          }
        } catch (_) {
          break; // No more ayahs
        }
      }
    }

    return resultMap;
  }

  /// Fetch interpretive translation from Quran.com Translations API (ayah-by-ayah for a full surah)
  /// Endpoint: GET /api/v4/quran/translations/{translation_id}?chapter_number={chapter}
  Future<Map<int, String>> _fetchTranslationFromQuranCom(int translationId, int surahNumber) async {
    final resultMap = <int, String>{};

    try {
      final res = await _dio.get(
        '$_quranComBase/quran/translations/$translationId',
        queryParameters: {'chapter_number': surahNumber},
      );

      if (res.statusCode == 200) {
        final translations = res.data['translations'] as List?;
        if (translations != null) {
          for (final t in translations) {
            // verse_key might be null in this endpoint — use resource_id or index
            final verseKey = t['verse_key'] as String?;
            int ayahNum = 0;

            if (verseKey != null) {
              final parts = verseKey.split(':');
              ayahNum = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
            }

            // Fallback: derive from verse_number or index
            if (ayahNum == 0) {
              ayahNum = t['verse_number'] as int? ?? (resultMap.length + 1);
            }

            final rawText = t['text'] as String? ?? '';
            // Strip HTML tags and footnote markers for clean display
            final cleanText = rawText
                .replaceAll(RegExp(r'<[^>]*>'), '')
                .replaceAll(RegExp(r'\[\d+\]'), '')
                .trim();
            if (ayahNum > 0 && cleanText.isNotEmpty) {
              resultMap[ayahNum] = cleanText;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Quran.com translation fetch failed for translation $translationId: $e');
    }

    return resultMap;
  }

  TafseerAudioSegment? getTanzeemSegmentForAyah(int surahNumber, int ayahNumber) {
    final segments = _tanzeemSurahMap[surahNumber];
    if (segments != null) {
      for (final seg in segments) {
        if (seg.containsAyah(ayahNumber)) return seg;
      }
    }
    return null;
  }

  List<TafseerAudioSegment> getTanzeemSegmentsForSurah(int surahNumber) {
    final list = _tanzeemSurahMap[surahNumber]?.toList() ?? [];
    list.sort((a, b) => a.part.compareTo(b.part));
    return list;
  }

  TafseerAudioSegment? getTaqiUsmaniSegmentForAyah(int surahNumber, int ayahNumber) {
    final segments = _taqiUsmaniSurahMap[surahNumber];
    if (segments != null) {
      for (final seg in segments) {
        if (seg.containsAyah(ayahNumber)) return seg;
      }
    }
    return null;
  }

  List<TafseerAudioSegment> getTaqiUsmaniSegmentsForSurah(int surahNumber) {
    final list = _taqiUsmaniSurahMap[surahNumber]?.toList() ?? [];
    list.sort((a, b) => a.part.compareTo(b.part));
    return list;
  }

  /// Generates the Audio URL for a specific Surah and Source
  /// If ayahNumber is provided and source supports per-ayah audio, returns per-ayah URL
  String? getAudioUrl(
    TafseerSource source,
    int surahNumber, {
    int? ayahNumber,
    String? surahName,
  }) {
    if (source.audioUrlPattern == null) {
      return null;
    }

    String url = source.audioUrlPattern!;
    
    // Replace {surah} with surah number (no padding)
    url = url.replaceAll('{surah}', surahNumber.toString());
    
    // Replace {surah_000} with 001, 012, 114 format
    final surahPadded = surahNumber.toString().padLeft(3, '0');
    url = url.replaceAll('{surah_000}', surahPadded);
    
    // Replace {surah_name} if provided
    if (surahName != null) {
      url = url.replaceAll('{surah_name}', surahName);
    }
    
    // For per-ayah audio, replace {ayah} patterns
    if (ayahNumber != null && source.audioPatternType == AudioPatternType.perAyah) {
      final ayahPadded = ayahNumber.toString().padLeft(3, '0');
      url = url.replaceAll('{ayah_000}', ayahPadded);
      
      // Also support {ayah} without padding
      url = url.replaceAll('{ayah}', ayahNumber.toString());
      
      // Support {surah_ayah} format like "001_001"
      url = url.replaceAll('{surah_ayah}', '${surahPadded}_$ayahPadded');
    }
    
    return url;
  }

  /// Gets per-ayah tafseer audio URL using multiple fallback strategies
  /// NOTE: for Tanzeem.org, we select a segment based on ayah ranges.
  String? getPerAyahAudioUrl(
    TafseerSource source,
    int surahNumber,
    int ayahNumber, {
    String? surahName,
    int? globalAyahNumber, // Global ayah number (1-6236) for some APIs
  }) {
    // Tanzeem.org segmented mapping (recommended audio tafseer path)
    // Used for:
    // - `ur-tafsir-bayan-ul-quran` (mixed: text from API + audio segments from Tanzeem)
    // - `ur-israr-tanzeem-04198` (audio-only)
    if (source.id == 'ur-israr-tanzeem-04198' || source.id == 'ur-tafsir-bayan-ul-quran') {
      return getTanzeemSegmentForAyah(surahNumber, ayahNumber)?.url;
    }

    if (source.id == 'ur-taqi-usmani-audio') {
      return getTaqiUsmaniSegmentForAyah(surahNumber, ayahNumber)?.url;
    }

    // Pattern-based audio sources
    if (source.audioUrlPattern == null) return null;

    if (source.audioPatternType == AudioPatternType.perAyah) {
      return getAudioUrl(source, surahNumber, ayahNumber: ayahNumber, surahName: surahName);
    }

    // Surah-level audio sources
    return getAudioUrl(source, surahNumber, surahName: surahName);
  }
  
  /// Checks if a source has per-ayah audio support
  bool hasPerAyahAudio(TafseerSource source) {
    return source.audioPatternType == AudioPatternType.perAyah;
  }

  /// Gets multiple fallback URLs for a source (useful for trying different URL patterns)
  List<String> getFallbackUrls(
    TafseerSource source,
    int surahNumber,
    int ayahNumber, {
    String? surahName,
  }) {
    final urls = <String>[];
    
    // Segmented sources mapping
    if (source.id == 'ur-israr-tanzeem-04198' || source.id == 'ur-tafsir-bayan-ul-quran') {
      final seg = getTanzeemSegmentForAyah(surahNumber, ayahNumber);
      if (seg != null) urls.add(seg.url);
      return urls;
    }

    if (source.id == 'ur-taqi-usmani-audio') {
      final seg = getTaqiUsmaniSegmentForAyah(surahNumber, ayahNumber);
      if (seg != null) urls.add(seg.url);
      return urls;
    }

    // Primary URL from pattern
    final primaryUrl = getPerAyahAudioUrl(
      source,
      surahNumber,
      ayahNumber,
      surahName: surahName,
    );
    if (primaryUrl != null) {
      urls.add(primaryUrl);
    }

    return urls.toSet().toList();
  }
}
