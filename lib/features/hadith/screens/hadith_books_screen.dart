import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  @override
  void initState() {
    super.initState();
    if (context.read<HadithBloc>().books.isEmpty) {
      context.read<HadithBloc>().add(const LoadHadithBooksEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F3), // Neumorphic base color
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF0F0F3),
        title: const TranslatedText('Ahadeeth (احادیث)', style: TextStyle(fontFamily: 'Jameel Noori', fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E))),
        centerTitle: true,
        actions: const [
          LanguageSelectorButton(),
        ],
      ),
      body: BlocBuilder<HadithBloc, HadithState>(
        buildWhen: (previous, current) {
          return current is HadithLoading || current is HadithBooksLoaded || current is HadithError || current is HadithInitial;
        },
        builder: (context, state) {
          final bloc = context.read<HadithBloc>();

          if (state is HadithLoading && bloc.books.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HadithError && bloc.books.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(state.message),
                    LiquidGlassButton(
                      label: 'Retry',
                      icon: const Icon(Icons.refresh, size: 18),
                      onTap: () => bloc.add(const LoadHadithBooksEvent()),
                    ),
                  ],
                ),
              ),
            );
          }

          final books = bloc.books;
          if (books.isEmpty) {
            return const Center(child: TranslatedText('No books available.'));
          }

          // Important Books first (Bukhari, Muslim, etc.)
          final topBooks = ['bukhari', 'muslim', 'tirmidhi', 'abudawud', 'nasai', 'ibnmajah', 'malik', 'darimi'];

          final sortedBooks = [...books]..sort((a, b) {
            int indexA = topBooks.indexOf(a.id);
            int indexB = topBooks.indexOf(b.id);
            if (indexA == -1) indexA = 999;
            if (indexB == -1) indexB = 999;
            return indexA.compareTo(indexB);
          });

          return GridView.builder(
            padding: const EdgeInsets.all(20.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: sortedBooks.length,
            itemBuilder: (context, index) {
              final book = sortedBooks[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HadithReaderScreen(book: book),
                    ),
                  );
                },
                child: LiquidGlassContainer(
                  borderRadius: 20,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.menu_book, size: 36, color: Color(0xFF1B5E20)),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: TranslatedText(
                          book.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${book.editions.length} ',
                            style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                          ),
                          Flexible(
                            child: TranslatedText(
                              'Translations',
                              style: TextStyle(fontSize: 10, color: Colors.grey[700]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
