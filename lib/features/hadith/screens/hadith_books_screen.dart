import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/language_selector_button.dart';
import '../../../core/widgets/translated_text.dart';
import '../state/hadith_bloc.dart';
import 'hadith_reader_screen.dart';
import '../../../shared/widgets/custom_button.dart';

class HadithBooksScreen extends StatefulWidget {
  const HadithBooksScreen({super.key});

  @override
  State<HadithBooksScreen> createState() => _HadithBooksScreenState();
}

class _HadithBooksScreenState extends State<HadithBooksScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final Map<String, String> _arabicBookNames = {
    'bukhari': 'صحيح البخاري',
    'muslim': 'صحيح مسلم',
    'tirmidhi': 'جامع الترمذي',
    'abudawud': 'سنن أبي داود',
    'nasai': 'سنن النسائي',
    'ibnmajah': 'سنن ابن ماجه',
    'malik': 'موطأ مالك',
    'darimi': 'سنن الدارمي',
    'nawawi40': 'الأربعون النووية',
    'nawawi': 'الأربعون النووية',
    'bulugh': 'بلوغ المرام',
    'hisn': 'حصن المسلم',
  };

  String _getArabicName(String id) {
    return _arabicBookNames[id.toLowerCase()] ?? 'كتاب الحديث';
  }

  @override
  void initState() {
    super.initState();
    if (context.read<HadithBloc>().books.isEmpty) {
      context.read<HadithBloc>().add(const LoadHadithBooksEvent());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: BlocBuilder<HadithBloc, HadithState>(
          buildWhen: (previous, current) {
            return current is HadithLoading ||
                current is HadithBooksLoaded ||
                current is HadithError ||
                current is HadithInitial;
          },
          builder: (context, state) {
            final bloc = context.read<HadithBloc>();

            if (state is HadithLoading && bloc.books.isEmpty) {
              return const _LoadingWidget();
            }

            if (state is HadithError && bloc.books.isEmpty) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const TranslatedText(
                        'انٹرنیٹ کنکشن نہیں',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 24),
                      LiquidGlassButton(
                        label: 'Retry',
                        icon: const Icon(Icons.refresh,
                            size: 18, color: Colors.white),
                        textStyle: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                        glassColor: const Color(0x33948160),
                        onTap: () => bloc.add(const LoadHadithBooksEvent()),
                      ),
                    ],
                  ),
                ),
              );
            }

            final books = bloc.books;
            if (books.isEmpty) {
              return const Center(
                  child: TranslatedText('No books available.'));
            }

            // Sort: Important Books first
            final topBooks = [
              'bukhari',
              'muslim',
              'tirmidhi',
              'abudawud',
              'nasai',
              'ibnmajah',
              'malik',
              'darimi'
            ];
            final sortedBooks = [...books]..sort((a, b) {
                int indexA = topBooks.indexOf(a.id);
                int indexB = topBooks.indexOf(b.id);
                if (indexA == -1) indexA = 999;
                if (indexB == -1) indexB = 999;
                return indexA.compareTo(indexB);
              });

            // Apply search filter
            final filteredBooks = _searchQuery.isEmpty
                ? sortedBooks
                : sortedBooks.where((b) {
                    final q = _searchQuery.toLowerCase();
                    return b.name.toLowerCase().contains(q) ||
                        _getArabicName(b.id).contains(_searchQuery);
                  }).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Search Bar ──
                _SearchBar(
                  controller: _searchController,
                  onChanged: (val) =>
                      setState(() => _searchQuery = val),
                ),
                // ── Section Header ──
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Hadith Books',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D2D2D),
                        ),
                      ),
                      Text(
                        '${filteredBooks.length} BOOKS',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // ── Grid ──
                Expanded(
                  child: filteredBooks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off,
                                  size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                'No books found',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.88,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: filteredBooks.length,
                          itemBuilder: (context, index) {
                            final book = filteredBooks[index];
                            return _BookCard(
                              arabicName: _getArabicName(book.id),
                              englishName: book.name,
                              editionCount: book.editions.length,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        HadithReaderScreen(book: book),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Search Bar ────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF2D2D2D),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                hintText: 'Search Hadith Books...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const LanguageSelectorButton(),
        ],
      ),
    );
  }
}

// ─── Book Card ─────────────────────────────────────────────────
class _BookCard extends StatelessWidget {
  final String arabicName;
  final String englishName;
  final int editionCount;
  final VoidCallback onTap;

  const _BookCard({
    required this.arabicName,
    required this.englishName,
    required this.editionCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFF0EDE6),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with gold tint container
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F1ED),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 26,
                color: Color(0xFF6B8FB5),
              ),
            ),
            const SizedBox(height: 14),
            // Arabic Title
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  arabicName,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Thuluth',
                    fontSize: 17,
                    color: Color(0xFF6B8FB5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // English Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                englishName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Edition count badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F1ED),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$editionCount Translations',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B8FB5),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Loading ──────────────────────────────────────────────────
class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF6B8FB5)),
            SizedBox(height: 16),
            TranslatedText(
              'احادیث لوڈ ہو رہی ہیں...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
