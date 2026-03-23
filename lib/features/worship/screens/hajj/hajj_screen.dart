import 'package:flutter/material.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/widgets/language_selector_button.dart';

class HajjScreen extends StatelessWidget {
  const HajjScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TranslatedText('Hajj', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: const [
          LanguageSelectorButton(),
        ],
      ),
      body: const Center(child: TranslatedText('Hajj Content')),
    );
  }
}
