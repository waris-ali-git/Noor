import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../state/quran_bloc.dart';
import '../../models/reading_mode.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../shared/widgets/custom_button.dart';

class WbwLanguageSelector extends StatelessWidget {
  final ValueChanged<ReadingDisplayMode>? onModeChanged;

  const WbwLanguageSelector({super.key, this.onModeChanged});

  static const Map<String, String> _languages = {
    'ur': 'Urdu (اردو)',
    'en': 'English',
    'fr': 'French (Français)',
    'hi': 'Hindi (हिन्दी)',
    'bn': 'Bengali (বাংলা)',
    'id': 'Indonesian (Bahasa Indonesia)',
    'inh': 'Ingush (ГӀалгӀай)',
    'fa': 'Persian (فارسی)',
    'ta': 'Tamil (தமிழ்)',
    'tr': 'Turkish (Türkçe)',
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuranBloc, QuranState>(
      builder: (context, state) {
        String currentLang = 'ur';
        if (state is SurahLoaded) currentLang = state.preferences.wbwLanguage;
        if (state is SurahWordByWordLoaded) currentLang = state.preferences.wbwLanguage;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TranslatedText(
                  'Select Language',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _languages.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final langCode = _languages.keys.elementAt(index);
                      final langName = _languages.values.elementAt(index);
                      final isSelected = currentLang == langCode;

                      return ListTile(
                        title: Text(
                          langName,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? const Color(0xFF1B5E20) : Colors.black87,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Color(0xFF1B5E20))
                            : null,
                        onTap: () {
                          // Change the WBW Language
                          context.read<QuranBloc>().add(
                            ChangeWbwLanguageEvent(languageCode: langCode),
                          );

                          // Then change the reading mode to Word-By-Word
                          context.read<QuranBloc>().add(
                            const ChangeReadingModeEvent(mode: ReadingDisplayMode.wordByWord),
                          );

                          onModeChanged?.call(ReadingDisplayMode.wordByWord);

                          // Pop the language selector dialog
                          Navigator.pop(context);
                          
                          // Pop the settings sheet if it was open
                          // We check if we are returning to the settings sheet or directly to reader
                          // Settings sheet usually expects 'pop'
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                LiquidGlassButton(
                  label: 'Cancel',
                  width: double.infinity,
                  height: 46,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
