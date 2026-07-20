import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/hadith.dart';
import '../state/hadith_bloc.dart';
import 'widgets/hadith_skeleton.dart';
import '../../../shared/widgets/custom_button.dart';
import 'package:quran_app/core/widgets/no_internet_widget.dart';

class HadithReaderScreen extends StatefulWidget {
  final HadithBook book;

  const HadithReaderScreen({super.key, required this.book});

  @override
  State<HadithReaderScreen> createState() => _HadithReaderScreenState();
}

class _HadithReaderScreenState extends State<HadithReaderScreen> {
  // All-translations mode: shows all language chips at top with multi-select.
  // The prior rendering crash has been fixed so this is safe to use as default.
  bool _showAllTranslations = true;

  @override
  void initState() {
    super.initState();
    context.read<HadithBloc>().add(SelectHadithBookEvent(book: widget.book));
  }

  void _showTranslationSelector(BuildContext context, List<HadithEdition> editions) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6D6D6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  'Select Translation',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: editions.length,
                    itemBuilder: (context, index) {
                      final edition = editions[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFF4F1ED),
                          child: const Icon(Icons.translate, color: Color(0xFF6B8FB5), size: 18),
                        ),
                        title: Text(
                          edition.language,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D2D2D),
                          ),
                        ),
                        subtitle: Text(
                          edition.name,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        onTap: () {
                          context.read<HadithBloc>().add(
                              ChangeHadithTranslationEvent(language: edition.language));
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguageFilter(BuildContext context, HadithAllTranslationsLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.8,
              expand: false,
              builder: (_, scrollController) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40, height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD6D6D6),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        'Select Languages',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      BlocBuilder<HadithBloc, HadithState>(
                        builder: (context, currentState) {
                          final s = currentState is HadithAllTranslationsLoaded ? currentState : state;
                          return Text(
                            '${s.selectedLanguages.length} of ${s.availableLanguages.length} selected',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF8E8E8E),
                              fontSize: 13,
                            ),
                          );
                        },
                      ),
                      const Divider(height: 20, color: Color(0xFFEEEEEE)),
                      Expanded(
                        child: BlocBuilder<HadithBloc, HadithState>(
                          builder: (context, currentState) {
                            final s = currentState is HadithAllTranslationsLoaded ? currentState : state;
                            return ListView.builder(
                              controller: scrollController,
                              itemCount: s.availableLanguages.length,
                              itemBuilder: (context, index) {
                                final lang = s.availableLanguages[index];
                                final isSelected = s.selectedLanguages.contains(lang);
                                return CheckboxListTile(
                                  title: Text(
                                    lang,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF2D2D2D),
                                    ),
                                  ),
                                  value: isSelected,
                                  activeColor: const Color(0xFF6B8FB5),
                                  checkColor: Colors.white,
                                  onChanged: (_) {
                                    context.read<HadithBloc>().add(
                                        ToggleHadithLanguageEvent(language: lang));
                                    setModalState(() {});
                                  },
                                );
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
          },
        );
      },
    );
  }

  bool _isRtlLanguage(String language) {
    final lower = language.toLowerCase();
    return lower.startsWith('arabic') || lower.startsWith('urdu') ||
        lower.startsWith('persian') || lower.startsWith('farsi') ||
        lower.startsWith('pashto') || lower.startsWith('sindhi') ||
        lower.startsWith('uyghur') || lower.startsWith('kurdish') ||
        lower.startsWith('hebrew');
  }

  bool _isUrduSelection(HadithState state) {
    if (state is HadithsLoaded) {
      return state.selectedTranslation.language.toLowerCase().contains('urdu');
    }
    if (state is HadithAllTranslationsLoaded) {
      return state.selectedLanguages.any((l) => l.toLowerCase().contains('urdu'));
    }
    if (state is HadithSectionsLoaded) {
      // If we're looking at sections, we check if the book has an Urdu edition
      return widget.book.editions.any((e) => e.language.toLowerCase().contains('urdu'));
    }
    return false;
  }

  bool _isArabicSelection(HadithState state) {
    if (state is HadithsLoaded) {
      return state.selectedTranslation.language.toLowerCase().contains('arabic');
    }
    if (state is HadithAllTranslationsLoaded) {
      return state.selectedLanguages.any((l) => l.toLowerCase().contains('arabic'));
    }
    if (state is HadithSectionsLoaded) {
      // If we're looking at sections, we check if the book has an Arabic edition
      return widget.book.editions.any((e) => e.language.toLowerCase().contains('arabic'));
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          widget.book.name,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2D2D2D),
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
        ),
        actions: [
          BlocBuilder<HadithBloc, HadithState>(
            builder: (context, state) {
              if (state is HadithSectionsLoaded || state is HadithsLoaded || state is HadithAllTranslationsLoaded) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _showAllTranslations ? Icons.translate : Icons.language,
                        color: _showAllTranslations ? const Color(0xFF6B8FB5) : Colors.black54,
                      ),
                      tooltip: _showAllTranslations ? 'All Translations (ON)' : 'Single Translation',
                      onPressed: () => setState(() => _showAllTranslations = !_showAllTranslations),
                    ),
                    if (!_showAllTranslations)
                      IconButton(
                        icon: const Icon(Icons.language, color: Colors.black54),
                        tooltip: 'Change Translation',
                        onPressed: () => _showTranslationSelector(context, widget.book.editions),
                      ),
                    if (_showAllTranslations && state is HadithAllTranslationsLoaded)
                      IconButton(
                        icon: const Icon(Icons.filter_list, color: Colors.black54),
                        tooltip: 'Filter Languages',
                        onPressed: () => _showLanguageFilter(context, state),
                      ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: BlocBuilder<HadithBloc, HadithState>(
        builder: (context, state) {
          if (state is HadithLoading) {
            return _buildLoadingSkeletons();
          }
          if (state is HadithError) {
            return NoInternetWidget(
              message: state.message,
              onRetry: () => context.read<HadithBloc>().add(SelectHadithBookEvent(book: widget.book)),
            );
          }
          if (state is HadithSectionsLoaded) return _buildSectionsList(state);
          if (state is HadithsLoaded) return _buildSingleTranslationView(state.selectedSection.name, state.selectedBook, state.selectedTranslation, state.hadiths);
          if (state is HadithsStreaming) return _buildStreamingTranslationView(state);
          if (state is HadithAllTranslationsLoaded) return _buildAllTranslationsView(state);
          if (state is HadithAllTranslationsStreaming) return _buildStreamingAllTranslationsView(state);
          return const SizedBox();
        },
      ),
    );
  }

  // ═══════ SECTIONS LIST ═══════
  Widget _buildSectionsList(HadithSectionsLoaded state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: state.sections.length,
      itemBuilder: (context, index) {
        final section = state.sections[index];
        return InkWell(
          onTap: () {
            if (_showAllTranslations) {
              context.read<HadithBloc>().add(LoadAllTranslationsForSectionEvent(section: section));
            } else {
              context.read<HadithBloc>().add(SelectHadithSectionEvent(section: section));
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(children: [
              // Number
              SizedBox(
                width: 36,
                child: Text(
                  (index + 1).toString().padLeft(2, '0'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFD6D6D6),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Middle Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.name,
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2D2D2D),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      section.firstHadith > 0
                          ? 'HADITHS ${section.firstHadith} - ${section.lastHadith}'
                          : 'CHAPTER ${index + 1}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8E8E8E),
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Right side
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFFE5E5E5),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  // ═══════ SINGLE TRANSLATION VIEW (Loaded) ═══════
  Widget _buildSingleTranslationView(String sectionName, HadithBook book, HadithEdition translation, List<HadithItem> hadiths) {
    final isArabic = translation.language.toLowerCase().contains('arabic');
    final isUrdu = translation.language.toLowerCase().contains('urdu');
    final isRtl = translation.direction == 'rtl';

    return Column(
      children: [
        _buildSectionHeader(sectionName, book),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: hadiths.length,
            itemBuilder: (context, index) {
              final hadith = hadiths[index];
              return _HadithVerseCard(
                hadithNumber: hadith.hadithNumber,
                text: hadith.text,
                isArabic: isArabic,
                isUrdu: isUrdu,
                isRtl: isRtl,
                grades: hadith.grades,
              );
            },
          ),
        ),
      ],
    );
  }

  // ═══════ SINGLE TRANSLATION VIEW (Streaming / Partial) ═══════
  Widget _buildStreamingTranslationView(HadithsStreaming state) {
    final isArabic = state.selectedTranslation.language.toLowerCase().contains('arabic');
    final isUrdu = state.selectedTranslation.language.toLowerCase().contains('urdu');
    final isRtl = state.selectedTranslation.direction == 'rtl';
    final loaded = state.loadedHadiths.length;
    final remaining = state.remainingHadiths;
    final totalChildCount = loaded + remaining;

    return Column(
      children: [
        _buildSectionHeader(state.selectedSection.name, state.selectedBook),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: totalChildCount,
            itemBuilder: (context, index) {
              if (index < loaded) {
                final hadith = state.loadedHadiths[index];
                return _HadithVerseCard(
                  hadithNumber: hadith.hadithNumber,
                  text: hadith.text,
                  isArabic: isArabic,
                  isUrdu: isUrdu,
                  isRtl: isRtl,
                  grades: hadith.grades,
                );
              } else {
                return HadithSkeletonCard(isArabic: isArabic);
              }
            },
          ),
        ),
      ],
    );
  }

  // ═══════ SKELETON LOADERS (Fallback for HadithLoading) ═══════
  Widget _buildLoadingSkeletons() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 6,
            separatorBuilder: (_, __) => const Divider(height: 32),
            itemBuilder: (context, index) => const HadithSkeletonCard(),
          ),
        ),
      ],
    );
  }

  // ═══════ ALL TRANSLATIONS VIEW ═══════
  Widget _buildAllTranslationsView(HadithAllTranslationsLoaded state) {
    return Column(
      children: [
        _buildSectionHeader(state.selectedSection.name, state.selectedBook),
        // Language filter chips — gold theme
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: const Color(0xFFFAFAFA),
          child: SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: state.availableLanguages.map((lang) {
                final isSelected = state.selectedLanguages.contains(lang);
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(lang, style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'PlusJakartaSans',
                      color: isSelected ? Colors.white : const Color(0xFF2D2D2D),
                    )),
                    selected: isSelected,
                    selectedColor: const Color(0xFF6B8FB5),
                    checkmarkColor: Colors.white,
                    backgroundColor: const Color(0xFFF4F1ED),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF6B8FB5) : const Color(0xFFD6D6D6),
                      width: 1,
                    ),
                    visualDensity: VisualDensity.compact,
                    onSelected: (_) {
                      context.read<HadithBloc>().add(ToggleHadithLanguageEvent(language: lang));
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: const Color(0xFFFAFAFA),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 14, color: Color(0xFF8E8E8E)),
              const SizedBox(width: 6),
              Text(
                '${state.hadiths.length} hadiths • ${state.selectedLanguages.length} languages selected',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF8E8E8E)),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: state.hadiths.length,
            itemBuilder: (context, index) {
              final hadith = state.hadiths[index];
              return _buildMultiTranslationCard(hadith, state.selectedLanguages, state.availableLanguages);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMultiTranslationCard(
      MultiTranslationHadith hadith,
      Set<String> selectedLanguages,
      List<String> orderedLanguages) {
    final visibleTranslations = <MapEntry<String, String>>[];
    for (final lang in orderedLanguages) {
      if (selectedLanguages.contains(lang) && hadith.translations.containsKey(lang)) {
        visibleTranslations.add(MapEntry(lang, hadith.translations[lang]!));
      }
    }

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B8FB5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Hadith ${hadith.hadithNumber}',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                if (hadith.grades.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  ..._buildInlineGrades(hadith.grades),
                ],
              ],
            ),
          ),
          ...visibleTranslations.map((entry) {
            final lang = entry.key;
            final text = entry.value;
            final isRtl = _isRtlLanguage(lang);
            final isArabic = lang.toLowerCase().startsWith('arabic');
            final isUrdu = lang.toLowerCase().contains('urdu');
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
              child: Column(
                crossAxisAlignment: isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (visibleTranslations.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        lang,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isArabic ? const Color(0xFF6B8FB5) : const Color(0xFF8E8E8E),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  SelectableText(
                    text,
                    textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                    textAlign: isRtl ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      fontFamily: isUrdu
                          ? 'Jameel Noori'
                          : (isArabic ? 'DigitalKhatt' : null),
                      fontSize: isArabic ? 24 : 17,
                      height: isArabic ? 2.0 : 1.7,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }),
          // Bottom divider like Quran card
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
        ],
      ),
    );
  }

  // ═══════ ALL TRANSLATIONS VIEW (Streaming) ═══════
  Widget _buildStreamingAllTranslationsView(HadithAllTranslationsStreaming state) {
    return Column(
      children: [
        _buildSectionHeader(state.selectedSection.name, state.selectedBook),
        Container(
          height: 50,
          color: const Color(0xFFFAFAFA),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.totalHadiths,
            separatorBuilder: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 2, thickness: 2, color: Colors.grey[300]),
            ),
            itemBuilder: (context, index) {
               return const HadithSkeletonCard(isArabic: true);
            },
          ),
        ),
      ],
    );
  }

  // ═══════ SHARED WIDGETS ═══════
  Widget _buildSectionHeader(String sectionName, HadithBook book) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: BlocBuilder<HadithBloc, HadithState>(
              builder: (context, state) {
                return Text(
                  sectionName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: _isUrduSelection(state)
                        ? 'Jameel Noori'
                        : (_isArabicSelection(state) ? 'DigitalKhatt' : null),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: const Color(0xFF2D2D2D),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 0,
            child: LiquidGlassButton(
              label: 'Chapters',
              icon: const Icon(Icons.list, size: 16, color: Color(0xFF6B8FB5)),
              height: 36,
              textStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B8FB5),
              ),
              onTap: () => context.read<HadithBloc>().add(SelectHadithBookEvent(book: book)),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInlineGrades(List<HadithGrade> grades) {
    return grades.take(1).map((g) {
      final isSahih = g.grade.toLowerCase().contains('sahih');
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSahih
              ? const Color(0xFF6B8FB5).withValues(alpha: 0.08)
              : const Color(0xFFD9F1FD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSahih
                ? const Color(0xFF6B8FB5).withValues(alpha: 0.35)
                : const Color(0xFFA6C7F2),
            width: 1,
          ),
        ),
        child: Text(
          g.grade,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isSahih ? const Color(0xFF6B8FB5) : const Color(0xFF6B8FB5),
          ),
        ),
      );
    }).toList();
  }
}

// ─────────────────────────────────────────────
// HADITH VERSE CARD  (matches Quran _StandardAyahCard)
// ─────────────────────────────────────────────
class _HadithVerseCard extends StatelessWidget {
  final dynamic hadithNumber;
  final String text;
  final bool isArabic;
  final bool isUrdu;
  final bool isRtl;
  final List<HadithGrade> grades;

  const _HadithVerseCard({
    required this.hadithNumber,
    required this.text,
    required this.isArabic,
    required this.isUrdu,
    required this.isRtl,
    required this.grades,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top row: number badge + inline grade ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B8FB5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Hadith $hadithNumber',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                if (grades.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  ..._buildInlineGrade(),
                ],
              ],
            ),
          ),

          // ── Main hadith text ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
            child: SelectableText(
              text,
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              textAlign: isRtl ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                fontFamily: isUrdu
                    ? 'Jameel Noori'
                    : (isArabic ? 'DigitalKhatt' : null),
                fontSize: isArabic ? 24 : 17,
                height: isArabic ? 2.0 : 1.7,
                color: Colors.black87,
              ),
            ),
          ),

          // ── Grade chips below text ──
          if (grades.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: grades.map((g) {
                  final isSahih = g.grade.toLowerCase().contains('sahih');
                  return Chip(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(
                      color: isSahih
                          ? const Color(0xFF6B8FB5).withValues(alpha: 0.4)
                          : const Color(0xFFA6C7F2),
                      width: 1,
                    ),
                    label: Text(
                      '${g.grade} (${g.name})',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isSahih
                            ? const Color(0xFF6B8FB5)
                            : const Color(0xFF90BDE7),
                      ),
                    ),
                    backgroundColor: isSahih
                        ? const Color(0xFF6B8FB5).withValues(alpha: 0.08)
                        : const Color(0xFFD9F1FD),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildInlineGrade() {
    return grades.take(1).map((g) {
      final isSahih = g.grade.toLowerCase().contains('sahih');
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSahih
              ? const Color(0xFF6B8FB5).withValues(alpha: 0.08)
              : const Color(0xFFD9F1FD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSahih
                ? const Color(0xFF6B8FB5).withValues(alpha: 0.35)
                : const Color(0xFFA6C7F2),
            width: 1,
          ),
        ),
        child: Text(
          g.grade,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isSahih ? const Color(0xFF6B8FB5) : const Color(0xFF6B8FB5),
          ),
        ),
      );
    }).toList();
  }
}

