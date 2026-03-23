import 'package:flutter/material.dart';
import '../../../core/widgets/translated_text.dart';
import '../../../core/widgets/language_selector_button.dart';
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
        'icon': Icons.pan_tool_alt_rounded, // Using standard icon as placeholder
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
      appBar: AppBar(
        title: const TranslatedText('5 Pillars of Islam', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: const [
          LanguageSelectorButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TranslatedText(
              'Explore the foundational acts of worship in Islam.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: pillars.length,
                itemBuilder: (context, index) {
                  final pillar = pillars[index];
                  return _buildPillarCard(context, pillar);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillarCard(BuildContext context, Map<String, dynamic> pillar) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => pillar['screen'] as Widget),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (pillar['color'] as MaterialColor).shade100,
                (pillar['color'] as MaterialColor).shade50,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: (pillar['color'] as MaterialColor).shade200,
                  child: Icon(
                    pillar['icon'] as IconData,
                    size: 30,
                    color: (pillar['color'] as MaterialColor).shade800,
                  ),
                ),
                const SizedBox(height: 16),
                TranslatedText(
                  pillar['title'] as String,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: (pillar['color'] as MaterialColor).shade900,
                  ),
                ),
                const SizedBox(height: 8),
                TranslatedText(
                  pillar['subtitle'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: (pillar['color'] as MaterialColor).shade700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
