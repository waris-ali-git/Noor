import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/quran/state/quran_bloc.dart';
import 'features/hadith/state/hadith_bloc.dart';
import 'features/tasbeeh/state/tasbeeh_bloc.dart';

import 'features/onboarding/screens/onboarding_screen.dart';
import 'core/state/language_cubit.dart';
import 'core/di.dart';

import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();
  await NotificationService().init();

  // TEST MODE: always show onboarding on every launch
  runApp(const IslamicApp());
}

class IslamicApp extends StatelessWidget {
  const IslamicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<LanguageCubit>()),
        BlocProvider(create: (_) => sl<QuranBloc>()),
        BlocProvider(create: (_) => sl<HadithBloc>()),
        BlocProvider(create: (_) => TasbeehBloc()),
      ],
      child: BlocBuilder<LanguageCubit, String>(
        builder: (context, currentLang) {
          return MaterialApp(
            title: 'Islamic App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF90BDE7),
                brightness: Brightness.light,
              ),
              fontFamily: 'Poppins',
            ),
            home: const OnboardingScreen(),
          );
        }),
    );
  }
}
