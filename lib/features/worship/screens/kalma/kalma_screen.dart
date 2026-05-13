import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../widgets/worship_sliver_header.dart';
import '../../models/kalma.dart';

class KalmaScreen extends StatefulWidget {
  const KalmaScreen({super.key});

  @override
  State<KalmaScreen> createState() => _KalmaScreenState();
}

class _KalmaScreenState extends State<KalmaScreen> {
  List<Kalma> _kalmas = [];
  bool _isLoading = true;

  // Colors for Kalma (Teal theme)
  final Color _deepColor = const Color(0xFF00695C); // Teal 800
  final Color _lightColor = const Color(0xFF4DB6AC); // Teal 300

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
      backgroundColor: const Color(0xFFFAF8FF),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                WorshipSliverHeader(
                  title: '6 Kalmas',
                  subtitle: 'The Declaration of Faith',
                  arabicTitle: 'الكَلِمَة',
                  icon: Icons.menu_book,
                  deepColor: _deepColor,
                  lightColor: _lightColor,
                  badgeText: 'Pillar #1',
                ),
                if (_kalmas.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: TranslatedText('Failed to load data.')),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildKalmaCard(context, _kalmas[index]),
                        childCount: _kalmas.length,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildKalmaCard(BuildContext context, Kalma kalma) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _deepColor.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row: Count & Name
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _lightColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      kalma.id.toString(),
                      style: TextStyle(
                        color: _deepColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TranslatedText(
                    kalma.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _deepColor,
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
              style: TextStyle(
                fontFamily: 'DigitalKhatt',
                fontSize: 32,
                height: 1.8,
                color: const Color(0xFF2D1B69).withOpacity(0.9),
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 24),
            
            // Transliteration Segment
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _lightColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _deepColor.withOpacity(0.1), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(
                    'Transliteration',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _deepColor,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TranslatedText(
                    kalma.transliteration,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: const Color(0xFF2D1B69).withOpacity(0.75),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Translation Segment
            TranslatedText(
              kalma.translation,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: const Color(0xFF2D1B69).withOpacity(0.85),
              ),
            ),
            const SizedBox(height: 24),
            
            // Description / Virtues
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_rounded, size: 20, color: _deepColor.withOpacity(0.8)),
                const SizedBox(width: 12),
                Expanded(
                  child: TranslatedText(
                    kalma.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF2D1B69).withOpacity(0.7),
                      height: 1.5,
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

