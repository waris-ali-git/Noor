import 'package:flutter/material.dart';
import '../../quran/screens/surah_list_screen.dart';
import '../../hadith/screens/hadith_books_screen.dart';
import '../../worship/screens/worship_home.dart';
import '../../../core/widgets/translated_text.dart';
import '../../../core/widgets/language_selector_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TranslatedText('Islamic App', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: const [
          LanguageSelectorButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SurahListScreen()));
              },
              child: const TranslatedText('Al-Quran', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HadithBooksScreen()));
              },
              child: const TranslatedText('Hadith', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const WorshipHomeScreen()));
              },
              child: const TranslatedText('Worship', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
