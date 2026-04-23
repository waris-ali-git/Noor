import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/widgets/translated_text.dart';
import '../models/dua_category_model.dart';
import '../services/dua_image_service.dart';

class DuaShareImageScreen extends StatefulWidget {
  final SingleDua dua;
  final String categoryName;

  const DuaShareImageScreen({
    super.key,
    required this.dua,
    required this.categoryName,
  });

  @override
  State<DuaShareImageScreen> createState() => _DuaShareImageScreenState();
}

class _DuaShareImageScreenState extends State<DuaShareImageScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final DuaImageService _imageService = DuaImageService();

  String? _bgImageUrl;
  bool _isLoadingImage = true;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _fetchNewBackground();
  }

  Future<void> _fetchNewBackground() async {
    if (!mounted) return;
    setState(() => _isLoadingImage = true);

    try {
      final url = await _imageService.fetchBackgroundImage();
      if (mounted) {
        setState(() {
          _bgImageUrl = url;
          _isLoadingImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingImage = false);
      }
    }
  }

  Future<void> _shareImage() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      // Small delay to ensure any UI rendering (like translated text) is fully complete
      await Future.delayed(const Duration(milliseconds: 300));

      final imageBytes = await _screenshotController.capture(delay: const Duration(milliseconds: 10));

      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = await File('${directory.path}/dua_share.png').create();
        await imagePath.writeAsBytes(imageBytes);

        await Share.shareXFiles(
          [XFile(imagePath.path)],
          text: 'Read this beautiful Dua: ${widget.categoryName}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Close button at top right
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 8),
              
              // The Image Card
              Flexible(
                child: _isLoadingImage
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : FractionallySizedBox(
                        widthFactor: 0.85,
                        child: RepaintBoundary(
                          child: Screenshot(
                            controller: _screenshotController,
                            child: _buildShareableCard(),
                          ),
                        ),
                      ),
              ),
              
              const SizedBox(height: 32),
              
              // Action buttons below the card
              if (!_isLoadingImage)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIconButton(
                      icon: Icons.refresh_rounded,
                      label: 'Change BG',
                      onTap: _fetchNewBackground,
                    ),
                    const SizedBox(width: 48),
                    _buildIconButton(
                      icon: Icons.share_rounded,
                      label: 'Share',
                      onTap: _shareImage,
                      isLoading: _isSharing,
                      isPrimary: true,
                    ),
                  ],
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLoading = false,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isPrimary ? const Color(0xFF1B8A5A) : Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: isPrimary ? null : Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareableCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.65,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            if (_bgImageUrl != null)
              Image.network(
                _bgImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade900),
              )
            else
              Container(color: Colors.grey.shade900),

            // Dark Overlay without Blur
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Glassmorphism Card
                  Flexible(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Arabic
                                Text(
                                  widget.dua.arabic,
                              style: const TextStyle(
                                fontFamily: 'DigitalKhatt',
                                fontSize: 28,
                                color: Colors.white,
                                height: 1.8,
                              ),
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                            ),
                            const SizedBox(height: 20),
                            
                            // Translation
                            TranslatedText(
                              widget.dua.translationEn,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                color: Colors.white.withValues(alpha: 0.95),
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Divider Line
                            Container(
                              height: 1,
                              width: 60,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Category / Title
                            TranslatedText(
                              widget.categoryName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.95),
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
              ),
            ),
            
            // App Watermark at the bottom
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Text(
                'Islamic App',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.5),
                  letterSpacing: 2.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }


}
