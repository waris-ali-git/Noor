import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../features/quran/services/quran_service.dart';
import '../features/quran/services/tafseer_service.dart';
import '../features/quran/state/quran_bloc.dart';
import '../features/hadith/services/hadith_service.dart';
import '../features/hadith/state/hadith_bloc.dart';
import '../features/quran/services/preferences_service.dart';
import '../features/quran/services/wbw_database_service.dart';
import '../features/dua/services/dua_service.dart';
import '../features/dua/state/dua_bloc.dart';

import 'services/translation_service.dart';
import 'state/language_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencies() async {
  // ─── Preferences ───────────────────────────
  await PreferencesService().init();

  // ─── Hive (parallel init for faster startup) ─
  await Hive.initFlutter();
  final boxes = await Future.wait([
    Hive.openBox<dynamic>('quran_cache'),
    Hive.openBox<dynamic>('hadith_cache'),
  ]);
  final quranCacheBox = boxes[0];
  final hadithCacheBox = boxes[1];

  // ─── Dio ───────────────────────────────────
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Accept': 'application/json',
      // Quran.com ke liye koi API key nahi chahiye
      // AlQuran.cloud ke liye bhi nahi
    },
  ));

  // Optional: Logging interceptor (debug mode mein)
  dio.interceptors.add(LogInterceptor(
    requestBody: false,
    responseBody: false,
    logPrint: (obj) => debugPrint('DIO: $obj'),
  ));

  // ─── Services ──────────────────────────────
  sl.registerLazySingleton<WbwDatabaseService>(
        () => WbwDatabaseService.instance,
  );
  sl.registerLazySingleton<QuranService>(
        () => QuranService(dio, quranCacheBox, sl<WbwDatabaseService>()),
  );
  sl.registerLazySingleton<TafseerService>(
        () => TafseerService(dio, quranCacheBox),
  );
  sl.registerLazySingleton<HadithService>(
        () => HadithService(dio, hadithCacheBox),
  );
  sl.registerLazySingleton<TranslationService>(
        () => TranslationService(dio),
  );

  // ─── BLoCs ─────────────────────────────────
  sl.registerFactory<LanguageCubit>(
        () => LanguageCubit(),
  );
  sl.registerFactory<QuranBloc>(
        () => QuranBloc(sl<QuranService>()),
  );
  sl.registerFactory<HadithBloc>(
        () => HadithBloc(sl<HadithService>()),
  );

  // ─── Dua ───────────────────────────────────
  sl.registerLazySingleton<DuaService>(
        () => DuaService.instance,
  );
  sl.registerFactory<DuaBloc>(
        () => DuaBloc(sl<DuaService>()),
  );

}