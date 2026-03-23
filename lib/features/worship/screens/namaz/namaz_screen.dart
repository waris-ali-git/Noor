import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/widgets/translated_text.dart';
import '../../../../core/widgets/language_selector_button.dart';
import '../../services/prayer_timing_service.dart';
import '../../models/prayer_timing.dart';
import '../../models/namaz_step.dart';
import '../../models/rakat_info.dart';
import '../../../quran/models/ayah.dart'; // For ArabicStringExtension

class NamazScreen extends StatelessWidget {
  const NamazScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const TranslatedText('Namaz', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: const [
            LanguageSelectorButton(),
          ],
          bottom: TabBar(
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Colors.grey[600],
            tabs: const [
              Tab(text: 'Timings', icon: Icon(Icons.access_time)),
              Tab(text: 'Tariqa', icon: Icon(Icons.accessibility_new)),
              Tab(text: 'Rakats', icon: Icon(Icons.format_list_numbered)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TimingsTab(),
            _TariqaTab(),
            _RakatsTab(),
          ],
        ),
      ),
    );
  }
}

// ─── TIMINGS TAB ─────────────────────────────────────────────────────────────
class _TimingsTab extends StatefulWidget {
  const _TimingsTab();

  @override
  State<_TimingsTab> createState() => _TimingsTabState();
}

class _TimingsTabState extends State<_TimingsTab> {
  PrayerTiming? _timing;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTimings();
  }

  Future<void> _fetchTimings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    final service = PrayerTimingService();
    // This will ask for location permission if not already granted.
    final data = await service.getTodayTimings();
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (data != null) {
          _timing = data;
        } else {
          _errorMessage = 'Could not fetch timings. Please ensure Location services are enabled.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            TranslatedText('Fetching precise timings for your location...'),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty || _timing == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              TranslatedText(_errorMessage, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchTimings,
                icon: const Icon(Icons.refresh),
                label: const TranslatedText('Retry'),
              )
            ],
          ),
        ),
      );
    }

    final t = _timing!;

    return RefreshIndicator(
      onRefresh: _fetchTimings,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hijri Date Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: Column(
              children: [
                const Icon(Icons.calendar_today, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(
                  '${t.hijriDate} ${t.hijriMonth} ${t.hijriYear}',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  t.gregorianDate,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const TranslatedText('Today\'s Prayers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildTimingRow('Fajr', t.fajr, Icons.wb_twilight),
          _buildTimingRow('Sunrise', t.sunrise, Icons.wb_sunny_outlined),
          _buildTimingRow('Dhuhr', t.dhuhr, Icons.wb_sunny),
          _buildTimingRow('Asr', t.asr, Icons.wb_cloudy),
          _buildTimingRow('Maghrib', t.maghrib, Icons.nights_stay_outlined),
          _buildTimingRow('Isha', t.isha, Icons.nights_stay),
        ],
      ),
    );
  }

  Widget _buildTimingRow(String name, String time, IconData icon) {
    // Format the time slightly if needed, Aladhan API returns e.g. "05:14 (PKT)", we can strip the timezone if we want
    final cleanTime = time.replaceAll(RegExp(r'\ \([^)]*\)'), ''); // Removes " (PKT)"

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.onPrimaryContainer),
        ),
        title: TranslatedText(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        trailing: Text(
          cleanTime,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    );
  }
}

// ─── TARIQA TAB ─────────────────────────────────────────────────────────────
class _TariqaTab extends StatefulWidget {
  const _TariqaTab();

  @override
  State<_TariqaTab> createState() => _TariqaTabState();
}

class _TariqaTabState extends State<_TariqaTab> {
  List<NamazStep> _steps = [];

  @override
  void initState() {
    super.initState();
    _loadSteps();
  }

  Future<void> _loadSteps() async {
    final String response = await rootBundle.loadString('lib/assets/data/worship/namaz_steps.json');
    final data = await json.decode(response);
    setState(() {
      _steps = (data as List).map((i) => NamazStep.fromJson(i)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_steps.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _steps.length,
      itemBuilder: (context, index) {
        final step = _steps[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      child: Text('${index + 1}'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TranslatedText(
                        step.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TranslatedText(
                  step.description,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
                if (step.arabicDua != null) ...[
                  const Divider(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(128),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          step.arabicDua!.cleanArabic,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontFamily: 'DigitalKhatt',
                            fontSize: 22,
                            height: 1.8,
                          ),
                        ),
                        if (step.duaTransliteration != null) ...[
                          const SizedBox(height: 12),
                          const TranslatedText('Transliteration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                          Text(step.duaTransliteration!, style: const TextStyle(fontStyle: FontStyle.italic)),
                        ],
                        if (step.duaTranslation != null) ...[
                          const SizedBox(height: 12),
                          const TranslatedText('Translation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                          TranslatedText(step.duaTranslation!),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── RAKATS TAB ─────────────────────────────────────────────────────────────
class _RakatsTab extends StatelessWidget {
  const _RakatsTab();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rakatData.length,
      itemBuilder: (context, index) {
        final r = rakatData[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ExpansionTile(
            title: TranslatedText(r.prayerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Row(
              children: [
                const TranslatedText('Total: '),
                Text('${r.total} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                const TranslatedText('Rakats'),
              ],
            ),
            childrenPadding: const EdgeInsets.all(16),
            expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildRakatRow('Sunnah (Before)', r.sunnahMuakkadahBefore + r.sunnahGhairMuakkadahBefore),
              _buildRakatRow('Fard', r.fard, isFard: true),
              _buildRakatRow('Sunnah (After)', r.sunnahAfter),
              _buildRakatRow('Nafl', r.nafl),
              if (r.witr > 0) _buildRakatRow('Witr', r.witr, isWitr: true),
              if (r.naflAfterWitr > 0) _buildRakatRow('Nafl (After Witr)', r.naflAfterWitr),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRakatRow(String type, int count, {bool isFard = false, bool isWitr = false}) {
    if (count == 0) return const SizedBox.shrink();
    
    Color badgeColor = Colors.grey[300]!;
    Color textColor = Colors.black87;

    if (isFard) {
      badgeColor = Colors.green[700]!;
      textColor = Colors.white;
    } else if (isWitr) {
      badgeColor = Colors.amber[700]!;
      textColor = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TranslatedText(type, style: TextStyle(fontWeight: isFard ? FontWeight.bold : FontWeight.normal)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
