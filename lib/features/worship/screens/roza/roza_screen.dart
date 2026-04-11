import 'package:flutter/material.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/widgets/language_selector_button.dart';
import '../../services/prayer_timing_service.dart';
import '../../models/prayer_timing.dart';

class RozaScreen extends StatefulWidget {
  const RozaScreen({super.key});

  @override
  State<RozaScreen> createState() => _RozaScreenState();
}

class _RozaScreenState extends State<RozaScreen> {
  final PrayerTimingService _timingService = PrayerTimingService();
  late Future<PrayerTiming?> _timingsFuture;

  @override
  void initState() {
    super.initState();
    _timingsFuture = _timingService.getTodayTimings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TranslatedText('Roza Companion', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: const [LanguageSelectorButton()],
      ),
      body: FutureBuilder<PrayerTiming?>(
        future: _timingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final timings = snapshot.data;
          
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (timings != null) 
                        _buildTimingCard(timings)
                      else 
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: TranslatedText("Unable to fetch timings. Please check location permissions and internet connection.", 
                              style: TextStyle(color: Colors.red)),
                          ),
                        ),
                      const SizedBox(height: 24),
                      _buildDuaCard(
                        "Sehri Dua (Intention to Fast)",
                        "وَبِصَوْمِ غَدٍ نَّوَيْتُ مِنْ شَهْرِ رَمَضَانَ",
                        "Wa bisawmi ghadinn nawaiytu min shahri ramadan",
                        "I intend to keep the fast for tomorrow in the month of Ramadan"
                      ),
                      const SizedBox(height: 16),
                      _buildDuaCard(
                        "Iftar Dua (Breaking the Fast)",
                        "اَللّٰهُمَّ اِنِّی لَکَ صُمْتُ وَبِکَ اٰمَنْتُ وَعَلَيْکَ تَوَکَّلْتُ وَعَلٰی رِزْقِکَ اَفْطَرْتُ",
                        "Allahumma inni laka sumtu wa bika aamantu wa 'alayka tawakkaltu wa 'ala rizqika aftartu",
                        "O Allah! I fasted for You and I believe in You and I put my trust in You and I break my fast with Your sustenance"
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildTimingCard(PrayerTiming timings) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage('assets/images/pattern.png'), // Will safely ignore if not present
          fit: BoxFit.cover,
          opacity: 0.1,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TranslatedText("Sehri Ends (Fajr)", style: TextStyle(color: Colors.white70)),
                  Text(timings.fajr.replaceAll(' (PKT)', ''), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const Icon(Icons.wb_twilight, color: Colors.orangeAccent, size: 40),
            ],
          ),
          const Divider(color: Colors.white24, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TranslatedText("Iftar Time (Maghrib)", style: TextStyle(color: Colors.white70)),
                  Text(timings.maghrib.replaceAll(' (PKT)', ''), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              const Icon(Icons.nights_stay, color: Colors.yellowAccent, size: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDuaCard(String title, String arabic, String transliteration, String translation) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TranslatedText(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 16),
            Text(
              arabic,
              textAlign: TextAlign.right,
              style: const TextStyle(fontFamily: 'UthmanicHafs', fontSize: 26, height: 1.5),
              textDirection: TextDirection.rtl,
            ),
            const Divider(height: 32),
            Text(
              transliteration,
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            TranslatedText(
              translation,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
