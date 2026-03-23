import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/widgets/language_selector_button.dart';
import '../../models/kalma.dart';

class KalmaScreen extends StatefulWidget {
  const KalmaScreen({super.key});

  @override
  State<KalmaScreen> createState() => _KalmaScreenState();
}

class _KalmaScreenState extends State<KalmaScreen> {
  List<Kalma> _kalmas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKalmas();
  }

  Future<void> _loadKalmas() async {
    try {
      final String response = await rootBundle.loadString('lib/assets/data/worship/kalmas.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        _kalmas = data.map((json) => Kalma.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading Kalmas: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TranslatedText('6 Kalmas of Islam', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: const [
          LanguageSelectorButton(),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _kalmas.isEmpty
              ? const Center(child: TranslatedText('Failed to load data.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _kalmas.length,
                  itemBuilder: (context, index) {
                    return _buildKalmaCard(context, _kalmas[index]);
                  },
                ),
    );
  }

  Widget _buildKalmaCard(BuildContext context, Kalma kalma) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 24.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row: Count & Name
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    kalma.id.toString(),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TranslatedText(
                    kalma.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            
            // Arabic Text (Not translated)
            Text(
              kalma.arabic,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'DigitalKhatt',
                fontSize: 28,
                height: 1.8,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 24),
            
            // Transliteration Segment
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(
                    'Transliteration:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TranslatedText(
                    kalma.transliteration,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Translation Segment
            TranslatedText(
              kalma.translation,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            
            // Description / Virtues
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 18, color: theme.colorScheme.outline),
                const SizedBox(width: 8),
                Expanded(
                  child: TranslatedText(
                    kalma.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}
