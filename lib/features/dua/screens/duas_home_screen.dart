import 'package:flutter/material.dart';

import '../../../core/widgets/translated_text.dart';
import '../../../core/widgets/language_selector_button.dart';
import '../data/dua_data.dart';
import '../models/dua_model.dart';

import 'dua_pdf_viewer_screen.dart';

import '../../../shared/widgets/custom_button.dart';

class DuasHomeScreen extends StatefulWidget {
  const DuasHomeScreen({super.key});

  @override
  State<DuasHomeScreen> createState() => _DuasHomeScreenState();
}

class _DuasHomeScreenState extends State<DuasHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F3), // Neumorphic base color
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF0F0F3),
        title: const TranslatedText(
          'Duas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E)),
        ),
        centerTitle: true,
        actions: const [LanguageSelectorButton()],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section (Liquid Glass)
                  LiquidGlassContainer(
                    borderRadius: 20,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.auto_stories_rounded,
                          size: 40,
                          color: const Color(0xFF1B5E20).withOpacity(0.7),
                        ),
                        const SizedBox(height: 12),
                        const TranslatedText(
                          'Read Islamic Duas',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1C1C1E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Duas list
          SliverPadding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final dua = allDuas[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildDuaCard(context, dua),
                  );
                },
                childCount: allDuas.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuaCard(BuildContext context, DuaModel dua) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                DuaPdfViewerScreen(
                  title: dua.title,
                  pdfUrl: dua.pdfUrl,
                ),
          ),
        );
      },
      child: LiquidGlassContainer(
        borderRadius: 20,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: dua.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(dua.icon, color: dua.color, size: 24),
            ),
            const SizedBox(width: 16),
            // Title & subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(
                    dua.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  TranslatedText(
                    dua.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF1C1C1E).withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, color: const Color(0xFF1C1C1E).withOpacity(0.3),
                size: 16),
          ],
        ),
      ),
    );
  }
}
