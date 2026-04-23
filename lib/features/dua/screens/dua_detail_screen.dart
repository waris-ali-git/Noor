import 'dart:ui' as dart_ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/language_selector_button.dart';
import '../../../core/widgets/translated_text.dart';
import '../models/dua_category_model.dart';
import 'dua_share_image_screen.dart';

class DuaDetailScreen extends StatelessWidget {
  final DuaCategory category;
  const DuaDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                itemCount: category.duas.length,
                itemBuilder: (ctx, i) => _DuaCard(
                  dua: category.duas[i],
                  index: i + 1,
                  categoryName: category.category,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF1C1C1E)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.category,
                  style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1C1C1E)),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                Text(category.categoryAr,
                  style: const TextStyle(fontFamily: 'DigitalKhatt', fontSize: 14, color: Color(0xFF1B8A5A)),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          const LanguageSelectorButton(),
        ],
      ),
    );
  }
}

class _DuaCard extends StatelessWidget {
  final SingleDua dua;
  final int index;
  final String categoryName;
  const _DuaCard({required this.dua, required this.index, required this.categoryName});

  void _copy(BuildContext context) {
    final text = '${dua.arabic}\n\n${dua.transliteration}\n\n${dua.translationEn}\n\nReference: ${dua.reference}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Dua copied!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _share(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Share Image',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return DuaShareImageScreen(
          dua: dua,
          categoryName: categoryName,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return BackdropFilter(
          filter: dart_ui.ImageFilter.blur(
            sigmaX: 8 * animation.value,
            sigmaY: 8 * animation.value,
          ),
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Index badge + reference
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B8A5A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('$index',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1B8A5A)),
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu_book_rounded, size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(dua.reference,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),

          // Arabic text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              dua.arabic,
              style: const TextStyle(
                fontFamily: 'DigitalKhatt',
                fontSize: 26,
                color: Color(0xFF1C1C1E),
                height: 2.2,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ),

          const SizedBox(height: 14),

          // Transliteration
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              dua.transliteration,
              style: GoogleFonts.lato(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: const Color(0xFF1B8A5A),
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Translation — uses TranslatedText so it changes with language selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TranslatedText(
              dua.translationEn,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xFF3D3D3D),
                height: 1.6,
              ),
            ),
          ),

          // Benefit (if any)
          if (dua.benefit != null && dua.benefit!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFE082), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('✨ ', style: TextStyle(fontSize: 13)),
                    Expanded(
                      child: TranslatedText(
                        dua.benefit!,
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF6D4C00), height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                _ActionBtn(icon: Icons.copy_rounded, label: 'Copy', onTap: () => _copy(context)),
                const SizedBox(width: 10),
                _ActionBtn(icon: Icons.share_rounded, label: 'Share', onTap: () => _share(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF1B8A5A)),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1B8A5A))),
          ],
        ),
      ),
    );
  }
}
