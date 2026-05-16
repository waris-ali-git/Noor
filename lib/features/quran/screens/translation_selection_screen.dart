import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../state/quran_bloc.dart';
import '../models/translation_edition.dart';

class TranslationSelectionScreen extends StatefulWidget {
  const TranslationSelectionScreen({super.key});

  @override
  State<TranslationSelectionScreen> createState() => _TranslationSelectionScreenState();
}

class _TranslationSelectionScreenState extends State<TranslationSelectionScreen> {
  String _searchQuery = '';
  final Set<String> _expandedLanguages = {};
  bool _hasInitializedExpansion = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      appBar: AppBar(
        title: const Text('Select Translation'),
        backgroundColor: const Color(0xFF90BDE7),
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
            child: TextField(
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search language or translator...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF90BDE7)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: BlocBuilder<QuranBloc, QuranState>(
        builder: (context, state) {
          final bloc = context.read<QuranBloc>();
          final translations = bloc.availableTranslations;

          if (translations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // current selection nikaalo taake expansion handle ho sake
          String currentSelection = '';
          if (state is SurahLoaded) currentSelection = state.preferences.selectedTranslation;
          if (state is SurahWordByWordLoaded) currentSelection = state.preferences.selectedTranslation;

          // Process and group translations
          final grouped = _groupAndFilterTranslations(translations, currentSelection);
          
          if (grouped.isEmpty) {
            return const Center(child: Text('No translations found match your search'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final languageGroup = grouped[index];
              final langCode = languageGroup.languageCode;
              final info = languageGroup.info;
              final editions = languageGroup.editions;
              final isExpanded = _expandedLanguages.contains(langCode);

              return Column(
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      key: PageStorageKey(langCode),
                      initiallyExpanded: isExpanded,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          if (expanded) {
                            _expandedLanguages.add(langCode);
                          } else {
                            _expandedLanguages.remove(langCode);
                          }
                        });
                      },

                      title: Text(
                        info.displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text('${editions.length} versions'),
                      trailing: Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: const Color(0xFF90BDE7),
                      ),
                      children: editions.map((edition) {
                        final isSelected = edition.identifier == currentSelection;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                          title: Text(
                            edition.englishName,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? const Color(0xFF90BDE7) : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            edition.name,
                            style: TextStyle(
                              fontFamily: langCode == 'ur' ? 'Jameel Noori' : (langCode == 'ar' ? 'DigitalKhatt' : null),
                            ),
                          ),
                          trailing: isSelected 
                            ? const Icon(Icons.check_circle, color: Color(0xFF90BDE7))
                            : null,
                          onTap: () {
                            bloc.add(ChangeTranslationEvent(edition: edition.identifier));
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(indent: 16, endIndent: 16),
                ],
              );
            },
          );
        },
      ),
    );
  }

  List<_LanguageGroup> _groupAndFilterTranslations(List<TranslationEdition> translations, String currentSelection) {
    // 1. Grouping
    final Map<String, List<TranslationEdition>> groups = {};
    for (var t in translations) {
      if (!groups.containsKey(t.language)) groups[t.language] = [];
      groups[t.language]!.add(t);
    }

    final List<_LanguageGroup> result = [];
    
    for (var langCode in groups.keys) {
      final editions = groups[langCode]!;
      final info = editions.first.languageInfo;
      
      // Filtering based on search query
      final matchesSearch = info.displayName.toLowerCase().contains(_searchQuery) || 
                            langCode.toLowerCase().contains(_searchQuery) ||
                            editions.any((e) => e.englishName.toLowerCase().contains(_searchQuery) || 
                                               e.name.toLowerCase().contains(_searchQuery));
      
      if (matchesSearch) {
        // Filter editions if search is active
        final filteredEditions = _searchQuery.isEmpty 
            ? editions 
            : editions.where((e) => e.englishName.toLowerCase().contains(_searchQuery) || 
                                   e.name.toLowerCase().contains(_searchQuery) ||
                                   info.displayName.toLowerCase().contains(_searchQuery)).toList();
        
        if (filteredEditions.isNotEmpty) {
          result.add(_LanguageGroup(langCode, info, filteredEditions));
          
          // Auto-expand if current selection is in this group (once per screen load)
          if (!_hasInitializedExpansion && filteredEditions.any((e) => e.identifier == currentSelection)) {
             _expandedLanguages.add(langCode);
          }
        }
      }
    }
    
    _hasInitializedExpansion = true;

    // 2. Sorting: Priority (ur, ar, en) first, then alphabetical
    result.sort((a, b) {
      final aPriority = priorityLanguages.indexOf(a.languageCode);
      final bPriority = priorityLanguages.indexOf(b.languageCode);
      
      if (aPriority != -1 && bPriority != -1) return aPriority.compare(bPriority);
      if (aPriority != -1) return -1;
      if (bPriority != -1) return 1;
      
      return a.info.displayName.compareTo(b.info.displayName);
    });

    return result;
  }
}

class _LanguageGroup {
  final String languageCode;
  final LanguageInfo info;
  final List<TranslationEdition> editions;
  _LanguageGroup(this.languageCode, this.info, this.editions);
}

extension on int {
  int compare(int other) => this - other;
}
