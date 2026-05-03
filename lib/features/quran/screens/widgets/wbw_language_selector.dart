import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../state/quran_bloc.dart';
import '../../models/reading_mode.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../shared/widgets/custom_button.dart';

class WbwLanguageSelector extends StatefulWidget {
  final ValueChanged<ReadingDisplayMode>? onModeChanged;

  const WbwLanguageSelector({super.key, this.onModeChanged});

  @override
  State<WbwLanguageSelector> createState() => _WbwLanguageSelectorState();
}

class _WbwLanguageSelectorState extends State<WbwLanguageSelector> {
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

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
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuranBloc, QuranState>(
      builder: (context, state) {
        String currentLang = 'ur';
        if (state is SurahLoaded) currentLang = state.preferences.wbwLanguage;
        if (state is SurahWordByWordLoaded) currentLang = state.preferences.wbwLanguage;

        // Filter languages based on search query
        final filteredLanguages = _languages.entries.where((entry) {
          final langName = entry.value.toLowerCase();
          return langName.contains(_searchQuery.toLowerCase());
        }).toList();

        return LiquidGlassContainer(
          width: 320,
          height: 500,
          borderRadius: 24,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TranslatedText(
                'Select Language',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 16),
              // Search Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: Icon(Icons.search, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              // Language List
              Expanded(
                child: filteredLanguages.isEmpty
                    ? const Center(child: TranslatedText('No results'))
                    : ListView.builder(
                        itemCount: filteredLanguages.length,
                        itemBuilder: (context, index) {
                          final langEntry = filteredLanguages[index];
                          final langCode = langEntry.key;
                          final langName = langEntry.value;
                          final isSelected = currentLang == langCode;

                          return ListTile(
                            dense: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            title: Text(
                              langName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.blueAccent : const Color(0xFF1C1C1E),
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, size: 18, color: Colors.blueAccent)
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

                              widget.onModeChanged?.call(ReadingDisplayMode.wordByWord);

                              // Pop the language selector dialog
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
