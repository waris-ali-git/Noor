import 'package:flutter/material.dart';
import '../../../core/widgets/translated_text.dart';
import '../../../core/widgets/language_selector_button.dart';
import '../../../shared/widgets/custom_button.dart';
import 'kalma/kalma_screen.dart';
import 'namaz/namaz_screen.dart';
import 'roza/roza_screen.dart';
import 'zakat/zakat_screen.dart';
import 'hajj/hajj_screen.dart';

class WorshipHomeScreen extends StatelessWidget {
  const WorshipHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> pillars = [
      {
        'title': 'Kalma',
        'subtitle': 'The Declaration of Faith',
        'icon': Icons.menu_book,
        'color': Colors.teal,
        'screen': const KalmaScreen(),
      },
      {
        'title': 'Namaz',
        'subtitle': 'The Five Daily Prayers',
        'icon': Icons.pan_tool_alt_rounded,
        'color': Colors.blue,
        'screen': const NamazScreen(),
      },
      {
        'title': 'Roza',
        'subtitle': 'Fasting in Ramadan',
        'icon': Icons.brightness_3,
        'color': Colors.purple,
        'screen': const RozaScreen(),
      },
      {
        'title': 'Zakat',
        'subtitle': 'Obligatory Charity',
        'icon': Icons.volunteer_activism,
        'color': Colors.orange,
        'screen': const ZakatScreen(),
      },
      {
        'title': 'Hajj',
        'subtitle': 'Pilgrimage to Makkah',
        'icon': Icons.location_on,
        'color': Colors.brown,
        'screen': const HajjScreen(),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F3), // Match neumorphic base
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F0F3),
        elevation: 0,
        title: const TranslatedText('5 Pillars of Islam', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1C1C1E))),
        centerTitle: true,
        actions: const [
          LanguageSelectorButton(),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: TranslatedText(
                'Explore the foundational acts of worship in Islam.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: pillars.length,
              itemBuilder: (context, index) {
                final pillar = pillars[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => pillar['screen'] as Widget),
                    );
                  },
                  child: LiquidGlassContainer(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(16),
                    glassColor: (pillar['color'] as Color).withOpacity(0.12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (pillar['color'] as Color).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            pillar['icon'] as IconData,
                            color: (pillar['color'] as Color),
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TranslatedText(
                          pillar['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C1C1E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        TranslatedText(
                          pillar['subtitle'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: const Color(0xFF1C1C1E).withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
