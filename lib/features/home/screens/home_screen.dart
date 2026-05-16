import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/widgets/custom_button.dart';
import '../../quran/screens/surah_list_screen.dart';
import '../../hadith/screens/hadith_books_screen.dart';
import '../../worship/screens/worship_home.dart';
import '../../dua/screens/duas_home_screen.dart';
import '../../qibla/screens/qibla_compass.dart';
import '../../tasbeeh/screens/tasbeeh_home.dart';
import '../../tasbeeh/state/tasbeeh_bloc.dart';
import '../../../../shared/icons/icomoon.dart';
import '../asma_ul_husna_screen.dart';
import '../asma_un_nabi_screen.dart';
import '../../prophets/prophets_list_screen.dart';
import '../../../core/widgets/language_selector_button.dart';
import '../../../core/widgets/translated_text.dart';
import '../widgets/streak_widget.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/constants.dart';

// ──────────────────────────────────────────────────────────
// Colour Palette
// ──────────────────────────────────────────────────────────
const _bg = Color(0xFFF4FBFE); // Ice White
const _gold1 = Color(0xFFD9F1FD); // Powder Blue (hero gradient start)
const _gold2 = Color(0xFFA6C7F2); // Baby Blue   (hero gradient end / icon tint)
const _clockClr = Color(0xFF2D5F8A); // deep blue
const _orange = Color(0xFF90BDE7); // Carolina Blue (replaces orange accent)
const _cardBg = Color(0xFFF4FBFE); // Ice White card bg
const _muted = Color(0xFF6B8FB5); // steel blue muted
const _dark = Color(0xFF1A2E44); // deep navy dark text

// ──────────────────────────────────────────────────────────
// Prayer Time Calculator  (simplified Adhan algorithm)
// ──────────────────────────────────────────────────────────
class _PC {
  static double _dtr(double d) => d * math.pi / 180;

  static double _s(double d) => math.sin(_dtr(d));

  static double _c(double d) => math.cos(_dtr(d));

  static double _ac(double x) => math.acos(x.clamp(-1.0, 1.0)) * 180 / math.pi;

  static double _at(double x) => math.atan(x) * 180 / math.pi;

  static double _a2(double y, double x) => math.atan2(y, x) * 180 / math.pi;

  static double _fx(double a, {double r = 360.0}) => a - r * (a / r).floor();

  static List<double> _sun(int y, int m, int d, double lng, double tz) {
    if (m <= 2) {
      y--;
      m += 12;
    }
    double A = (y / 100).floorToDouble();
    double B = 2 - A + (A / 4).floorToDouble();
    double jd = (365.25 * (y + 4716)).floorToDouble() +
        (30.6001 * (m + 1)).floorToDouble() +
        d +
        B -
        1524.5;
    double D = jd - 2451545.0;
    double g = _fx(357.529 + 0.98560028 * D);
    double q = _fx(280.459 + 0.98564736 * D);
    double L = _fx(q + 1.915 * _s(g) + 0.020 * _s(2 * g));
    double e = 23.439 - 0.00000036 * D;
    double ra = _fx(_a2(_c(e) * _s(L), _c(L)) / 15, r: 24.0);
    double decl = math.asin((_s(e) * _s(L)).clamp(-1.0, 1.0)) * 180 / math.pi;
    double eqt = q / 15 - ra;
    double mid = 12 - eqt - lng / 15 + tz;
    return [decl, mid];
  }

  static double _ha(double alt, double lat, double decl) {
    double cosH = (_s(alt) - _s(decl) * _s(lat)) / (_c(decl) * _c(lat));
    return _ac(cosH) / 15;
  }

  static double _asrAlt(double lat, double decl) {
    double el = 90 - (lat - decl).abs();
    double cot = _c(el) / _s(el).clamp(0.001, 1.0);
    return _at(1.0 / (1 + cot));
  }

  static Map<String, DateTime> compute({
    required int y,
    required int m,
    required int d,
    required double lat,
    required double lng,
    required double tz,
  }) {
    final sun = _sun(y, m, d, lng, tz);
    final decl = sun[0];
    final mid = sun[1];
    final sunH = _ha(-0.833, lat, decl);

    DateTime toDateTime(double h) {
      final mins = (((h % 24) + 24) % 24 * 60).round();
      return DateTime(y, m, d, mins ~/ 60, mins % 60);
    }

    return {
      'Fajr': toDateTime(mid - _ha(-18, lat, decl)),
      'Dhuhr': toDateTime(mid + 0.033),
      'Asr': toDateTime(mid + _ha(_asrAlt(lat, decl), lat, decl)),
      'Maghrib': toDateTime(mid + sunH),
      'Isha': toDateTime(mid + _ha(-17, lat, decl)),
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
        children: List.generate(
            _pages.length,
            (i) => Offstage(
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
        color: const Color(0xFFF4FBFE), // Ice White bottom nav
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
              _tile(
                  0, const IconData(0xe906, fontFamily: 'CustomIcons'), 'Home'),
              _tile(1, const IconData(0xe900, fontFamily: 'CustomIcons'),
                  'Quran'),
              _tile(2, const IconData(0xe903, fontFamily: 'CustomIcons'),
                  'Qibla'),
              // Tasbih: opens via Navigator
              _tileNav(const IconData(0xe907, fontFamily: 'CustomIcons'),
                  'Tasbih', context),
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
            Text(label,
                style: TextStyle(
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
        final tasbeehBloc = ctx.read<TasbeehBloc>();
        Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: tasbeehBloc,
              child: const TasbeehHomeScreen(),
            ),
          ),
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
            Text(label,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w400, color: _muted)),
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
  String _next = '...';
  Duration _rem = Duration.zero;

  // Location
  String _loc = '';
  double _lat = 24.8607; // Karachi default
  double _lng = 67.0011;

  // User name
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    NotificationService().scheduleInactivityReminder();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
        _upd();
      });
    });
    _initLocation();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // ── Location & prayer calculation ─────────────────────
  Future<void> _initLocation() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.whileInUse ||
          perm == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.low),
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
            final j = json.decode(res.body) as Map;
            final addr = j['address'] as Map? ?? {};
            final city = addr['city'] ?? addr['town'] ?? addr['village'] ?? '';
            final cc = addr['country'] ?? '';
            if (mounted)
              setState(() => _loc = city.isNotEmpty ? '$city, $cc' : cc);
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
    final n = DateTime.now();
    final tz = n.timeZoneOffset.inMinutes / 60.0;
    final t = _PC.compute(
      y: n.year,
      m: n.month,
      d: n.day,
      lat: _lat,
      lng: _lng,
      tz: tz,
    );
    if (mounted)
      setState(() {
        _pt = t;
        _upd();
      });

    // Schedule notifications for prayers
    int id = 0;
    _pt.forEach((name, time) {
      NotificationService().schedulePrayerNotification(
        id: id++,
        title: 'Time for $name',
        body: 'It is time for $name prayer.',
        scheduledTime: time,
      );
    });
  }

  void _upd() {
    if (_pt.isEmpty) return;
    for (final name in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
      final t = _pt[name];
      if (t != null && _now.isBefore(t)) {
        _next = name;
        _rem = t.difference(_now);
        return;
      }
    }
    _next = 'Fajr';
    _rem = const Duration(hours: 5);
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
    const mn = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
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
                    if (_userName.isNotEmpty) ...[
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 20, top: 4, bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Salaam,',
                              style: GoogleFonts.montserrat(
                                fontSize: 23,
                                fontWeight: FontWeight.w300,
                                color: TasbeehColors.standardBlue,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 24),
                              child: ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                  colors: [
                                    Color(0xFF3487D1),
                                    Color(0xFF90BDE7)
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  _userName,
                                  style: GoogleFonts.rochester(
                                    fontSize: 39,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    if (name.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNameDialog();
      });
    } else {
      if (mounted) setState(() => _userName = name);
    }
  }

  void _showNameDialog() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon or text
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFD9F1FD), Color(0xFFA6C7F2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'السَّلَامُ',
                      style: TextStyle(
                        fontFamily: 'Jameel Noori',
                        fontSize: 20,
                        color: Color(0xFF1A2E44),
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'What should we call you?',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A2E44),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your name to personalize your experience.',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: const Color(0xFF6B8FB5),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A2E44),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Your name...',
                    filled: true,
                    fillColor: const Color(0xFFF4FBFE),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF90BDE7),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () async {
                      final enteredName = nameController.text.trim();
                      if (enteredName.isNotEmpty) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('user_name', enteredName);
                        if (mounted) setState(() => _userName = enteredName);
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5BA3D9), Color(0xFF90BDE7)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'Continue',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _appBar() => Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const StreakWidget(),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () =>
                            NotificationService().showTestNotification(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.notifications_active_rounded,
                              color: Color(0xFFF39C12), size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const LanguageSelectorButton(),
              ],
            ),
          ],
        ),
      );

  Widget _featureButtons() {
    return Center(
      child: LayoutBuilder(builder: (context, constraints) {
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
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AsmaUnNabiScreen())),
            ),
            SizedBox(width: spacing),
            // Allah Button
            _featureCircleButton(
              imagePath: 'lib/assets/images/allah_name.png',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AsmaUlHusnaScreen())),
            ),
          ],
        );
      }),
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
              color: const Color(0xFF90BDE7).withValues(alpha: 0.25),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF90BDE7).withValues(alpha: 0.25),
                        // Pastel blue shade
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF90BDE7).withValues(alpha: 0.25),
                        // Pastel blue shade
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(children: [
                        Expanded(
                            child: Column(children: [
                          TranslatedText('REMAINING TIME',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                fontSize: 8.5,
                                letterSpacing: 1.3,
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(height: 2),
                          Text(
                            '$_next  $_remStr',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ])),
                        Container(
                            width: 1,
                            height: 36,
                            color: Colors.white.withValues(alpha: 0.3)),
                        Expanded(
                            child: Column(children: [
                          Text(_dateStr,
                              style: GoogleFonts.montserrat(
                                fontSize: 8.5,
                                letterSpacing: 0.5,
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w600,
                              )),
                          const SizedBox(height: 2),
                          Text(
                            _loc.isEmpty ? 'Locating...' : _loc,
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
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
      _FItem('Quran', const IconData(0xe900, fontFamily: 'CustomIcons'),
          () => _nav(const SurahListScreen())),
      _FItem('Worship', const IconData(0xe904, fontFamily: 'CustomIcons'),
          () => _nav(const WorshipHomeScreen())),
      _FItem('Hadith', Icomoon.hadith, () => _nav(const HadithBooksScreen())),
      _FItem('Supplication', const IconData(0xe902, fontFamily: 'CustomIcons'),
          () => _nav(const DuasHomeScreen())),
      _FItem('Prophets', Icomoon.prophetStory,
          () => _nav(const ProphetsListScreen())),
      _FItem('Qibla', const IconData(0xe903, fontFamily: 'CustomIcons'),
          () => _nav(const QiblaCompassScreen())),
    ];

    final gradients = [
      const [Color(0xFFDFF5F6), Color(0xFFA7F7FF)], // Cyan
      const [Color(0xFFF1F1FC), Color(0xFFAEAEFF)], // Lavender
      const [Color(0xFFEAF7ED), Color(0xFFB0FFC4)], // Mint Green
      const [Color(0xFFFCECF3), Color(0xFFFAA9D0)], // Soft Pink
      const [Color(0xFFF4FBFE), Color(0xFF9EE1FF)], // Light Blue
      const [Color(0xFFFFF4E6), Color(0xFFFBD9AE)], // Soft Orange
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF4FCFE), Color(0xFFEDFDF5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
          children: List.generate(
              items.length, (i) => _featureCell(items[i], gradients[i])),
        ),
      ),
    );
  }

  Widget _featureCell(_FItem f, List<Color> gradientColors) => GestureDetector(
        onTap: f.onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[1].withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  f.icon,
                  size: 26,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Colors.black12,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            TranslatedText(f.label,
                style: GoogleFonts.montserrat(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: _dark,
                )),
          ],
        ),
      );

  // ── Prayer Times Section ──────────────────────────────
  Widget _prayerSection() {
    return _CircularPrayerTracker(
      pt: _pt,
      ptStr: _ptStr,
      nextPrayer: _next,
    );
  }
}

// ── Circular Prayer Tracker ───────────────────────────────
class _CircularPrayerTracker extends StatefulWidget {
  final Map<String, DateTime> pt;
  final String Function(String) ptStr;
  final String nextPrayer;

  const _CircularPrayerTracker({
    super.key,
    required this.pt,
    required this.ptStr,
    required this.nextPrayer,
  });

  @override
  State<_CircularPrayerTracker> createState() => _CircularPrayerTrackerState();
}

class _CircularPrayerTrackerState extends State<_CircularPrayerTracker>
    with SingleTickerProviderStateMixin {
  // Fajr, Dhuhr/Jumma, Asr, Maghrib, Isha
  List<bool> _ticked = [false, false, false, false, false];
  late AnimationController _animCtrl;
  late Animation<double> _progressAnim;

  // Track sequence of checked indices
  List<int> _checkedSequence = [];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _progressAnim = Tween<double>(begin: 0, end: 0)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggleTick(int index) {
    if (!_ticked[index]) {
      final keys = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
      final bool isFriday = DateTime.now().weekday == DateTime.friday;
      final String displayTitle = (index == 1 && isFriday) ? 'Jumma' : keys[index];
      final prayerTime = widget.pt[keys[index]];
      
      if (prayerTime != null && DateTime.now().isBefore(prayerTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$displayTitle time has not started yet!'),
            backgroundColor: Colors.redAccent.withOpacity(0.8),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }
    }

    setState(() {
      _ticked[index] = !_ticked[index];
      if (_ticked[index]) {
        _checkedSequence.add(index);
      } else {
        _checkedSequence.remove(index);
      }

      double oldProgress = _progressAnim.value;
      double newProgress = _checkedSequence.length / 5.0;
      _progressAnim = Tween<double>(begin: oldProgress, end: newProgress)
          .animate(
              CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
      _animCtrl.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isFriday = DateTime.now().weekday == DateTime.friday;
    final String secondPrayerName = isFriday ? 'Jumma' : 'Dhuhr';

    final names = ['Fajr', secondPrayerName, 'Asr', 'Maghrib', 'Isha'];
    // Soft pastel colors matching the theme
    final colors = [
      const Color(0xFFA7F7FF),
      // Cyan (Fajr)
      isFriday ? const Color(0xFFFBD9AE) : const Color(0xFFAEAEFF),
      // Jumma(Orange) / Dhuhr(Lavender)
      const Color(0xFFB0FFC4),
      // Mint Green (Asr)
      const Color(0xFFFAA9D0),
      // Pink (Maghrib)
      const Color(0xFF9EE1FF),
      // Light Blue (Isha)
    ];

    List<Color> activeColors = [];
    for (int i = 0; i < 5; i++) {
      if (_ticked[i]) activeColors.add(colors[i]);
    }

    if (activeColors.length == 1) {
      activeColors.add(activeColors.first);
    } else if (activeColors.isEmpty) {
      activeColors = [
        Colors.grey.withOpacity(0.1),
        Colors.grey.withOpacity(0.1)
      ];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF4FCFE), Color(0xFFEDFDF5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.055),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Left side: Fajr (0) & Asr (2)
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildPrayerItem(0, names, colors),
                      const SizedBox(height: 8),
                      _buildPrayerItem(2, names, colors),
                    ],
                  ),
                ),

                // Center: Donut Chart
                Expanded(
                  flex: 3,
                  child: Transform.translate(
                    offset: const Offset(-30, 17),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: AnimatedBuilder(
                            animation: _progressAnim,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: _PrayerDonutPainter(
                                  progress: _progressAnim.value,
                                  gradientColors: activeColors,
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${_checkedSequence.length}/5',
                                        style: GoogleFonts.poppins(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1A2E44),
                                          height: 1.1,
                                        ),
                                      ),
                                      Text(
                                        'prayed',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF6B8FB5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                  ),
                ),

                // Right side: Dhuhr (1) & Maghrib (3)
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildPrayerItem(1, names, colors),
                      const SizedBox(height: 8),
                      _buildPrayerItem(3, names, colors),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            // Bottom: Isha (4)
            SizedBox(
              width: 130,
              child: _buildPrayerItem(4, names, colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerItem(int i, List<String> names, List<Color> colors) {
    final String prayerKey = i == 1 ? 'Dhuhr' : names[i];
    final String time = widget.ptStr(prayerKey);
    return GestureDetector(
      onTap: () => _toggleTick(i),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Tick indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _ticked[i] ? colors[i] : Colors.transparent,
                border: Border.all(
                  color: _ticked[i]
                      ? colors[i]
                      : const Color(0xFF6B8FB5).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: _ticked[i]
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 8),
            // Name & Time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    names[i],
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: widget.nextPrayer == prayerKey
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: _ticked[i]
                          ? const Color(0xFF6B8FB5).withOpacity(0.5)
                          : const Color(0xFF1A2E44),
                      decoration:
                          _ticked[i] ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Text(
                    time,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B8FB5).withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerDonutPainter extends CustomPainter {
  final double progress;
  final List<Color> gradientColors;

  _PrayerDonutPainter({required this.progress, required this.gradientColors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background track
    final trackPaint = Paint()
      ..color = const Color(0xFF6B8FB5).withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi,
      false,
      trackPaint,
    );

    if (progress <= 0) return;

    final sweepAngle = 2 * math.pi * progress;

    List<double> stops = [];
    if (gradientColors.length == 2) {
      stops = [0.0, progress.clamp(0.0, 1.0)];
    } else {
      for (int i = 0; i < gradientColors.length; i++) {
        stops.add((i / (gradientColors.length - 1)) * progress);
      }
    }

    final fillPaint = Paint()
      ..shader = SweepGradient(
        colors: gradientColors,
        stops: stops,
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _PrayerDonutPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.gradientColors != gradientColors;
  }
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
