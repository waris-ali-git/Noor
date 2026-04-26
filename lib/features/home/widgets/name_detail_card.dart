import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class NameDetailCard extends StatefulWidget {
  final Map<String, String> data;
  final int index;

  const NameDetailCard({
    super.key,
    required this.data,
    required this.index,
  });

  @override
  State<NameDetailCard> createState() => _NameDetailCardState();
}

class _NameDetailCardState extends State<NameDetailCard> {
  final ScreenshotController screenshotController = ScreenshotController();

  Future<void> _shareName() async {
    try {
      final Uint8List? imageBytes = await screenshotController.capture();
      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = await File('${directory.path}/name_detail.png').create();
        await imagePath.writeAsBytes(imageBytes);

        await Share.shareXFiles(
          [XFile(imagePath.path)],
          text: 'Check out this beautiful name of Allah: ${widget.data['transliteration']} - ${widget.data['arabic']}\nMeaning: ${widget.data['meaning']}',
        );
      }
    } catch (e) {
      debugPrint('Error sharing name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Container(
      width: size.width * 0.9,
      constraints: const BoxConstraints(maxWidth: 450),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Screenshot(
            controller: screenshotController,
            child: Material(
              color: const Color(0xFFFDF9F0), // Lighter, more premium cream color
              borderRadius: BorderRadius.circular(32),
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.1),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                    width: 2,
                  ),
                  image: const DecorationImage(
                    image: NetworkImage('https://www.transparenttextures.com/patterns/islamic-art.png'),
                    opacity: 0.05,
                    repeat: ImageRepeat.repeat,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Name Number Label
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          'Name #${widget.index + 1}',
                          style: const TextStyle(
                            color: Color(0xFF8B6914),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Arabic name with specialized font
                      Text(
                        widget.data['arabic']!,
                        style: const TextStyle(
                          fontFamily: 'AsmaUlHusna', // Using the specialized font
                          fontSize: 64,
                          color: Color(0xFF1A1208),
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Decorative gold divider
                      _buildDecorativeDivider(),
                      
                      const SizedBox(height: 20),
                      
                      // Transliteration
                      Text(
                        widget.data['transliteration']!,
                        style: const TextStyle(
                          color: Color(0xFF1A1208),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Meaning
                      Text(
                        widget.data['meaning']!,
                        style: TextStyle(
                          color: const Color(0xFF8B6914).withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Detailed Description
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withOpacity(0.15),
                          ),
                        ),
                        child: Text(
                          widget.data['description'] ?? widget.data['meaning']!,
                          style: const TextStyle(
                            color: Color(0xFF4A3F35),
                            fontSize: 14,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Share Button (Outside the screenshot area for better UX)
          ElevatedButton.icon(
            onPressed: _shareName,
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            label: const Text('Share Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1208),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, const Color(0xFFD4AF37).withOpacity(0.6)],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(
            Icons.brightness_7, // Decorative star icon
            size: 14,
            color: const Color(0xFFD4AF37).withOpacity(0.8),
          ),
        ),
        Container(
          width: 40,
          height: 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFFD4AF37).withOpacity(0.6), Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }
}
