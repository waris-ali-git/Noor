import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../../shared/widgets/custom_button.dart';
import '../../quran/screens/surah_list_screen.dart';
import '../../hadith/screens/hadith_books_screen.dart';
import '../../worship/screens/worship_home.dart';
import '../../dua/screens/duas_home_screen.dart';
import '../../qibla/screens/qibla_compass.dart';
import '../asma_ul_husna_screen.dart';
import '../asma_un_nabi_screen.dart';
import '../../prophets/prophets_list_screen.dart';
import '../../../core/widgets/language_selector_button.dart';
import '../../../core/widgets/translated_text.dart';

// ──────────────────────────────────────────────────────────
// Colour Palette
// ──────────────────────────────────────────────────────────
const _bg        = Color(0xFFFFF8F2);
const _gold1     = Color(0xFFFFD28A);
const _gold2     = Color(0xFFFFAA5A);
const _clockClr  = Color(0xFF7A4400);
const _orange    = Color(0xFFFF8C00);
const _cardBg    = Color(0xFFFFFFFF);
const _muted     = Color(0xFF9E8B7B);
const _dark      = Color(0xFF3D2B1F);

// ──────────────────────────────────────────────────────────
// Prayer Time Calculator  (simplified Adhan algorithm)
// ──────────────────────────────────────────────────────────
class _PC {
  static double _dtr(double d) => d * math.pi / 180;
  static double _s(double d)   => math.sin(_dtr(d));
  static double _c(double d)   => math.cos(_dtr(d));
  static double _ac(double x)  => math.acos(x.clamp(-1.0, 1.0)) * 180 / math.pi;
  static double _at(double x)  => math.atan(x) * 180 / math.pi;
  static double _a2(double y, double x) => math.atan2(y, x) * 180 / math.pi;
  static double _fx(double a, {double r = 360.0}) => a - r * (a / r).floor();

  static List<double> _sun(int y, int m, int d, double lng, double tz) {
    if (m <= 2) { y--; m += 12; }
    double A  = (y / 100).floorToDouble();
    double B  = 2 - A + (A / 4).floorToDouble();
    double jd = (365.25 * (y + 4716)).floorToDouble() +
                (30.6001 * (m + 1)).floorToDouble() + d + B - 1524.5;
    double D  = jd - 2451545.0;
    double g  = _fx(357.529 + 0.98560028 * D);
    double q  = _fx(280.459 + 0.98564736 * D);
    double L  = _fx(q + 1.915 * _s(g) + 0.020 * _s(2 * g));
    double e  = 23.439 - 0.00000036 * D;
    double ra   = _fx(_a2(_c(e) * _s(L), _c(L)) / 15, r: 24.0);
    double decl = math.asin((_s(e) * _s(L)).clamp(-1.0, 1.0)) * 180 / math.pi;
    double eqt  = q / 15 - ra;
    double mid  = 12 - eqt - lng / 15 + tz;
    return [decl, mid];
  }

  static double _ha(double alt, double lat, double decl) {
    double cosH = (_s(alt) - _s(decl) * _s(lat)) / (_c(decl) * _c(lat));
    return _ac(cosH) / 15;
  }

  static double _asrAlt(double lat, double decl) {
    double el  = 90 - (lat - decl).abs();
    double cot = _c(el) / _s(el).clamp(0.001, 1.0);
    return _at(1.0 / (1 + cot));
  }

  static Map<String, DateTime> compute({
    required int y, required int m, required int d,
    required double lat, required double lng, required double tz,
  }) {
    final sun   = _sun(y, m, d, lng, tz);
    final decl  = sun[0];
    final mid   = sun[1];
    final sunH  = _ha(-0.833, lat, decl);

    DateTime toDateTime(double h) {
      final mins = (((h % 24) + 24) % 24 * 60).round();
      return DateTime(y, m, d, mins ~/ 60, mins % 60);
    }

    return {
      'Fajr'   : toDateTime(mid - _ha(-18,              lat, decl)),
      'Dhuhr'  : toDateTime(mid + 0.033),
      'Asr'    : toDateTime(mid + _ha(_asrAlt(lat, decl), lat, decl)),
      'Maghrib': toDateTime(mid + sunH),
      'Isha'   : toDateTime(mid + _ha(-17,              lat, decl)),
    };
  }
}


// ──────────────────────────────────────────────────────────
// Main Shell  (HomeScreen = shell with bottom navigation)
// ──────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;

  // Lazily activate tabs so heavy screens don't load until visited
  final _activated = [true, false, false];

  final _pages = const <Widget>[
    _HomeTab(),
    SurahListScreen(),
    QiblaCompassScreen(),
  ];

  void _onNav(int i) => setState(() {
    _idx = i;
    if (i < _activated.length) _activated[i] = true;
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: List.generate(_pages.length, (i) => Offstage(
          offstage: _idx != i,
          child: _activated[i] ? _pages[i] : const SizedBox.shrink(),
        )),
      ),
      bottomNavigationBar: _BottomNav(current: _idx, onTap: _onNav),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Bottom Navigation Bar
// ──────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _tile(0, const IconData(0xe906, fontFamily: 'CustomIcons'), 'Home'),
              _tile(1, const IconData(0xe900, fontFamily: 'CustomIcons'), 'Quran'),
              _tile(2, const IconData(0xe903, fontFamily: 'CustomIcons'), 'Qibla'),
              // Tasbih: opens via Navigator since screen is empty
              _tileNav(const IconData(0xe907, fontFamily: 'CustomIcons'), 'Tasbih', context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(int idx, IconData iconData, String label) {
    final sel = current == idx;
    return GestureDetector(
      onTap: () => onTap(idx),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, color: sel ? _orange : _muted, size: 20),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(
              fontSize: 11,
              fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
              color: sel ? _orange : _muted,
            )),
          ],
        ),
      ),
    );
  }

  Widget _tileNav(IconData iconData, String label, BuildContext ctx) {
    return GestureDetector(
      onTap: () {
        // Tasbeeh screen is empty; just show snackbar for now
        ScaffoldMessenger.of(ctx).showSnackBar(
          const SnackBar(content: Text('Tasbih coming soon!'), duration: Duration(seconds: 1)),
        );
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, color: _muted, size: 28),
            const SizedBox(height: 3),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: _muted)),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Home Tab  (the actual home content)
// ──────────────────────────────────────────────────────────
class _HomeTab extends StatefulWidget {
  const _HomeTab();
  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  // Prayer times
  Map<String, DateTime> _pt = {};
  String   _next = '...';
  Duration _rem  = Duration.zero;

  // Location
  String _loc = '';
  double _lat = 24.8607;   // Karachi default
  double _lng = 67.0011;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() { _now = DateTime.now(); _upd(); });
    });
    _initLocation();
  }

  @override
  void dispose() { _timer.cancel(); super.dispose(); }

  // ── Location & prayer calculation ─────────────────────
  Future<void> _initLocation() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.whileInUse || perm == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
        );
        _lat = pos.latitude;
        _lng = pos.longitude;
        // Reverse geocode with Nominatim
        try {
          final res = await http.get(
            Uri.parse('https://nominatim.openstreetmap.org/reverse'
                '?format=json&lat=$_lat&lon=$_lng'),
            headers: {'User-Agent': 'IslamicApp/1.0', 'Accept-Language': 'en'},
          ).timeout(const Duration(seconds: 6));
          if (res.statusCode == 200) {
            final j    = json.decode(res.body) as Map;
            final addr = j['address'] as Map? ?? {};
            final city = addr['city'] ?? addr['town'] ?? addr['village'] ?? '';
            final cc   = addr['country'] ?? '';
            if (mounted) setState(() => _loc = city.isNotEmpty ? '$city, $cc' : cc);
          }
        } catch (_) {
          if (mounted) setState(() => _loc = '${_lat.toStringAsFixed(1)}°N');
        }
      } else {
        if (mounted) setState(() => _loc = 'Karachi, Pakistan');
      }
    } catch (_) {
      if (mounted) setState(() => _loc = 'Karachi, Pakistan');
    }
    _calcPrayers();
  }

  void _calcPrayers() {
    final n  = DateTime.now();
    final tz = n.timeZoneOffset.inMinutes / 60.0;
    final t  = _PC.compute(
      y: n.year, m: n.month, d: n.day,
      lat: _lat, lng: _lng, tz: tz,
    );
    if (mounted) setState(() { _pt = t; _upd(); });
  }

  void _upd() {
    if (_pt.isEmpty) return;
    for (final name in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
      final t = _pt[name];
      if (t != null && _now.isBefore(t)) {
        _next = name;
        _rem  = t.difference(_now);
        return;
      }
    }
    _next = 'Fajr';
    _rem  = const Duration(hours: 5);
  }

  // ── Helpers ───────────────────────────────────────────
  String _p2(int n) => n.toString().padLeft(2, '0');

  String get _remStr {
    final h = _rem.inHours;
    final m = _rem.inMinutes % 60;
    final s = _rem.inSeconds % 60;
    return '$h:${_p2(m)}:${_p2(s)}';
  }

  String get _dateStr {
    const mn = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${_now.day} ${mn[_now.month - 1]}, ${_now.year}';
  }

  String _ptStr(String name) {
    final t = _pt[name];
    return t == null ? '--:--' : '${_p2(t.hour)}:${_p2(t.minute)}';
  }

  void _nav(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  // ── Build ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bg,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _appBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _hero(),
                            _quickGrid(),
                          ],
                        ),
                        // Top spacing is 2 + 218 = 220 for Hero. 
                        // The space between Hero and Grid is 18. Center = 229.
                        // Button height = 64. 229 - (64/2) = 197.
                        Positioned(
                          top: 210,
                          left: 0,
                          right: 0,
                          child: _featureButtons(),
                        ),
                      ],
                    ),
                    _prayerSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────
  Widget _appBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    child: Row(children: [
      IconButton(icon: const Icon(Icons.menu, color: _dark), onPressed: () {}),
      const Expanded(child: TranslatedText(
        'ISLAMIC APP',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 17, fontWeight: FontWeight.w900,
          color: _dark, letterSpacing: 2.5,
        ),
      )),
      const LanguageSelectorButton(),
    ]),
  );

  Widget _featureButtons() {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate screen width to align exactly above the outer columns
          double screenWidth = MediaQuery.of(context).size.width;
          // The grid has 3 items, the gaps are between them.
          // By giving the gap roughly 1/3 of the width, the buttons slide outward.
          double spacing = (screenWidth * 0.33).clamp(80.0, 200.0); 
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Muhammad Button
              _featureCircleButton(
                imagePath: 'lib/assets/images/muhammad_name.png',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AsmaUnNabiScreen())),
              ),
              SizedBox(width: spacing),
              // Allah Button
              _featureCircleButton(
                imagePath: 'lib/assets/images/allah_name.png',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AsmaUlHusnaScreen())),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _featureCircleButton({
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white, width: 3),
        ),
      ),
    );
  }

  // ── Hero Card  (live clock + mosque silhouette) ───────
  Widget _hero() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 218,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_gold1, _gold2],
          ),
        ),
        child: Stack(children: [
          // Home picture from assets
          Positioned.fill(
            child: Image.asset(
              'lib/assets/images/homepic.png',
              fit: BoxFit.cover,
            ),
          ),
          // Content overlay
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ── Daily Dua ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1), // <-- DUA KE BACKGROUND KA COLOR YAHAN HAI
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'رَبِّ زِدْنِي عِلْمًا',
                          style: GoogleFonts.amiri(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '"O my Lord, increase me in knowledge"',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                // ── Info row (remaining time | date + location) ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15), // <-- BOTTOM INFO KE BACKGROUND KA COLOR YAHAN HAI
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(children: [
                    Expanded(child: Column(children: [
                      TranslatedText('REMAINING TIME', 
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          fontSize: 8.5, letterSpacing: 1.3,
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w600,
                      )),
                      const SizedBox(height: 2),
                      Text(
                        '$_next  $_remStr',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          fontSize: 13, fontWeight: FontWeight.w400, color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ])),
                    Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.3)),
                    Expanded(child: Column(children: [
                      Text(_dateStr, style: GoogleFonts.montserrat(
                        fontSize: 8.5, letterSpacing: 0.5,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      )),
                      const SizedBox(height: 2),
                      Text(
                        _loc.isEmpty ? 'Locating...' : _loc,
                        style: GoogleFonts.montserrat(
                          fontSize: 13, fontWeight: FontWeight.w400, color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ])),
                  ]),
                ),
              ],
            ),
          ),
        ]),
      ),
    ),
  );

  // ── Quick Feature Grid ────────────────────────────────
  Widget _quickGrid() {
    final items = [
      _FItem('Quran',    const IconData(0xe900, fontFamily: 'CustomIcons'), () => _nav(const SurahListScreen())),
      _FItem('Worship',  const IconData(0xe904, fontFamily: 'CustomIcons'), () => _nav(const WorshipHomeScreen())),
      _FItem('Hadith',   const IconData(0xe901, fontFamily: 'CustomIcons'), () => _nav(const HadithBooksScreen())),
      _FItem('Duas',     const IconData(0xe902, fontFamily: 'CustomIcons'), () => _nav(const DuasHomeScreen())),
      _FItem('Prophets', const IconData(0xe905, fontFamily: 'CustomIcons'), () => _nav(const ProphetsListScreen())),
      _FItem('Qibla',    const IconData(0xe903, fontFamily: 'CustomIcons'), () => _nav(const QiblaCompassScreen())),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.055),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          childAspectRatio: 0.95,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          children: items.map(_featureCell).toList(),
        ),
      ),
    );
  }

  Widget _featureCell(_FItem f) => GestureDetector(
    onTap: f.onTap,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LiquidGlassContainer(
          width: 58,
          height: 58,
          borderRadius: 16,
          isTransparent: false,
          glassColor: Colors.white,
          child: Center(
            child: Icon(f.icon, size: 26, color: _gold2),
          ),
        ),
        const SizedBox(height: 8),
        TranslatedText(f.label, style: GoogleFonts.montserrat(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: _dark,
        )),
      ],
    ),
  );

  // ── Prayer Times Section ──────────────────────────────
  Widget _prayerSection() {
    final prayers = [
      _PItem('Fajr',    '🌅', _ptStr('Fajr')),
      _PItem('Dhuhr',   '☀️', _ptStr('Dhuhr')),
      _PItem('Asr',     '🌤', _ptStr('Asr')),
      _PItem('Maghrib', '🌙', _ptStr('Maghrib')),
      _PItem('Isha',    '⭐', _ptStr('Isha')),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 16, 12),
          child: TranslatedText('Prayer Times', style: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.bold, color: _dark,
          )),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: prayers.length,
            itemBuilder: (_, i) => _prayerCard(prayers[i], prayers[i].name == _next),
          ),
        ),
      ],
    );
  }

  Widget _prayerCard(_PItem p, bool isNext) => Container(
    width: 88,
    margin: const EdgeInsets.only(right: 10),
    decoration: BoxDecoration(
      color: isNext ? _orange.withValues(alpha: 0.12) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: isNext
          ? Border.all(color: _orange.withValues(alpha: 0.35), width: 1.5)
          : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(p.emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 3),
        TranslatedText(p.name, style: GoogleFonts.poppins(
          fontSize: 11, color: _muted, fontWeight: FontWeight.w500,
        )),
        Text(p.time, style: GoogleFonts.poppins(
          fontSize: 15, fontWeight: FontWeight.bold,
          color: isNext ? _orange : _dark,
        )),
      ],
    ),
  );
}

// ── Data models ───────────────────────────────────────────

class _FItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _FItem(this.label, this.icon, this.onTap);
}

class _PItem {
  final String name, emoji, time;
  const _PItem(this.name, this.emoji, this.time);
}
