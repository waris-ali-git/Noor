import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

// ─── Kaaba coordinates ────────────────────────────────────────────────────────
const double _kaabaLat = 21.4225;
const double _kaabaLng = 39.8262;

// ─── Qibla math ───────────────────────────────────────────────────────────────
double _toRad(double deg) => deg * math.pi / 180;
double _toDeg(double rad) => rad * 180 / math.pi;

double calculateQiblaDirection(double lat, double lng) {
  final phi1 = _toRad(lat);
  final phi2 = _toRad(_kaabaLat);
  final dL   = _toRad(_kaabaLng - lng);
  final y    = math.sin(dL) * math.cos(phi2);
  final x    = math.cos(phi1) * math.sin(phi2) -
      math.sin(phi1) * math.cos(phi2) * math.cos(dL);
  return (_toDeg(math.atan2(y, x)) + 360) % 360;
}

// ─── Kaaba Color Palette ──────────────────────────────────────────────────────
const _white        = Color(0xFFFFFFFF);
const _kiswahBlack  = Color(0xFF0D0A04);
const _kiswahBlack2 = Color(0xFF1A1208);
const _gold         = Color(0xFFC9A84C);
const _goldDeep     = Color(0xFF8B6914);
const _goldPale     = Color(0xFFF0D98A);
const _goldFaint    = Color(0xFFE8D9A0);
const _textGold     = Color(0xFF7A6530);
const _shadowGold   = Color(0x18C9A84C);

// ─── Screen ───────────────────────────────────────────────────────────────────
class QiblaCompassScreen extends StatefulWidget {
  const QiblaCompassScreen({super.key});
  @override
  State<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends State<QiblaCompassScreen>
    with TickerProviderStateMixin {
  double? _qiblaAngle;
  double  _deviceHeading = 0;
  String  _statusMsg     = 'Locating your position…';
  bool    _hasError      = false;
  bool    _isAligned     = false;
  String  _locationSource = '';

  late final AnimationController _pulseCtrl;
  late final AnimationController _shimmerCtrl;
  late final AnimationController _entryCtrl;
  late final Animation<double>   _entryScale;
  late final Animation<double>   _entryOpacity;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _shimmerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4500))
      ..repeat();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _entryScale   = CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut);
    _entryOpacity = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _initLocation();
  }

  // ── Location: 4-source fallback chain (no API key needed) ─────────────────
  //
  //  1. Geolocator HIGH accuracy  → best (GPS + network fused)
  //  2. Geolocator MEDIUM accuracy → faster, still good
  //  3. ip-api.com free IP lookup → works indoors, ~city-level
  //  4. Last known position        → stale but better than nothing
  //
  Future<void> _initLocation() async {
    // Permission check
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied)
      perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.deniedForever) {
      // No GPS at all — try IP lookup as fallback
      final ok = await _tryIpLocation();
      if (!ok) {
        setState(() {
          _hasError  = true;
          _statusMsg = 'Location permission denied.\nEnable in Settings.';
        });
      }
      _listenCompass();
      return;
    }

    // 1️⃣ High accuracy GPS (best precision)
    bool got = await _tryGPS(LocationAccuracy.high, timeoutSec: 12);

    // 2️⃣ Medium accuracy (faster lock)
    if (!got) got = await _tryGPS(LocationAccuracy.medium, timeoutSec: 8);

    // 3️⃣ Free IP geolocation (no key needed, works indoors)
    if (!got) got = await _tryIpLocation();

    // 4️⃣ Last known position
    if (!got) got = await _tryLastKnown();

    if (!got) {
      setState(() {
        _hasError  = true;
        _statusMsg = 'Could not determine location.\nTap Retry.';
      });
    }

    _listenCompass();
  }

  Future<bool> _tryGPS(LocationAccuracy accuracy, {required int timeoutSec}) async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: accuracy,
          timeLimit: Duration(seconds: timeoutSec),
        ),
      );
      _applyPosition(
        pos.latitude, pos.longitude,
        source: accuracy == LocationAccuracy.high ? 'GPS' : 'Network',
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ip-api.com — completely free, no key, 45 req/min limit
  Future<bool> _tryIpLocation() async {
    try {
      final res = await http
          .get(Uri.parse('http://ip-api.com/json/?fields=lat,lon,city,status'))
          .timeout(const Duration(seconds: 6));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 'success') {
          final lat = (data['lat'] as num).toDouble();
          final lon = (data['lon'] as num).toDouble();
          final city = data['city'] ?? '';
          _applyPosition(lat, lon, source: 'IP ($city)');
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  Future<bool> _tryLastKnown() async {
    try {
      final pos = await Geolocator.getLastKnownPosition();
      if (pos != null) {
        _applyPosition(pos.latitude, pos.longitude, source: 'Cached');
        return true;
      }
    } catch (_) {}
    return false;
  }

  void _applyPosition(double lat, double lng, {String source = ''}) {
    if (!mounted) return;
    setState(() {
      _qiblaAngle     = calculateQiblaDirection(lat, lng);
      _hasError       = false;
      _locationSource = source;
      _statusMsg =
      '${lat.toStringAsFixed(4)}° N, ${lng.toStringAsFixed(4)}° E';
    });
    if (!_entryCtrl.isCompleted) _entryCtrl.forward();
  }

  void _listenCompass() {
    FlutterCompass.events?.listen((event) {
      if (!mounted) return;
      final h = event.heading ?? 0;
      setState(() {
        _deviceHeading = h;
        if (_qiblaAngle != null) {
          final diff = ((_qiblaAngle! - h) % 360 + 360) % 360;
          _isAligned = diff < 5 || diff > 355;
        }
      });
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _shimmerCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  double get _needleAngle {
    if (_qiblaAngle == null) return 0;
    return _toRad(_qiblaAngle! - _deviceHeading);
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: _white,
        body: Column(
          children: [
            _buildKiswahHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 28),
                    _buildCompassArea(),
                    const SizedBox(height: 24),
                    _buildBottomInfo(),
                    const SizedBox(height: 28),
                    _buildKaabaIllustration(),
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

  // ── Kiswah header ─────────────────────────────────────────────────────────
  Widget _buildKiswahHeader() {
    return Container(
      color: _kiswahBlack,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  color: _gold,
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    'QIBLA DIRECTION',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: _gold, letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            Container(height: 1.5, color: _gold),
            Container(height: 3),
            Container(height: 0.4, color: _gold.withOpacity(0.35)),
          ],
        ),
      ),
    );
  }

  // ── Compass ───────────────────────────────────────────────────────────────
  Widget _buildCompassArea() {
    return Center(
      child: SizedBox(
        width: 300, height: 300,
        child: AnimatedBuilder(
          animation: Listenable.merge([_pulseCtrl, _shimmerCtrl]),
          builder: (_, __) => Stack(
            alignment: Alignment.center,
            children: [
              _buildGlowRing(),
              _buildDial(),
              _buildCardinals(),
              if (_qiblaAngle != null) _buildNeedle(),
              _buildCenterJewel(),
              if (_qiblaAngle == null) _buildLoadingOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlowRing() => Container(
    width: 300, height: 300,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(
        color: _gold.withOpacity(0.10 + 0.07 * _pulseCtrl.value),
        blurRadius: 36, spreadRadius: 8,
      )],
    ),
  );

  Widget _buildDial() => Transform.rotate(
    angle: -_toRad(_deviceHeading),
    child: CustomPaint(
      size: const Size(300, 300),
      painter: _KiswahDialPainter(shimmer: _shimmerCtrl.value, isAligned: _isAligned),
    ),
  );

  Widget _buildCardinals() {
    const labels = ['N', 'E', 'S', 'W'];
    const angles = [0.0, 90.0, 180.0, 270.0];
    return Transform.rotate(
      angle: -_toRad(_deviceHeading),
      child: SizedBox(
        width: 300, height: 300,
        child: Stack(
          alignment: Alignment.center,
          children: List.generate(4, (i) {
            final rad = _toRad(angles[i]);
            const r = 112.0;
            return Transform.translate(
              offset: Offset(r * math.sin(rad), -r * math.cos(rad)),
              child: Text(labels[i],
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: i == 0 ? 17 : 13,
                    fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w500,
                    color: i == 0 ? _gold : _goldDeep,
                  )),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildNeedle() => ScaleTransition(
    scale: _entryScale,
    child: FadeTransition(
      opacity: _entryOpacity,
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (_, __) => Transform.rotate(
          angle: _needleAngle,
          child: CustomPaint(
            size: const Size(300, 300),
            painter: _KiswahNeedlePainter(pulse: _pulseCtrl.value, isAligned: _isAligned),
          ),
        ),
      ),
    ),
  );

  Widget _buildCenterJewel() => AnimatedContainer(
    duration: const Duration(milliseconds: 400),
    width: _isAligned ? 24 : 18,
    height: _isAligned ? 24 : 18,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: _kiswahBlack,
      border: Border.all(color: _gold, width: _isAligned ? 2 : 1.5),
      boxShadow: [BoxShadow(
        color: _gold.withOpacity(_isAligned ? 0.7 : 0.25),
        blurRadius: _isAligned ? 14 : 5,
      )],
    ),
    child: Center(
      child: Container(
        width: _isAligned ? 8 : 6,
        height: _isAligned ? 8 : 6,
        decoration: const BoxDecoration(shape: BoxShape.circle, color: _gold),
      ),
    ),
  );

  Widget _buildLoadingOverlay() => Container(
    width: 300, height: 300,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: _white.withOpacity(0.92),
    ),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_hasError)
            AnimatedBuilder(
              animation: _shimmerCtrl,
              builder: (_, __) => Transform.rotate(
                angle: _shimmerCtrl.value * 2 * math.pi,
                child: CustomPaint(size: const Size(48, 48), painter: _GoldRingPainter()),
              ),
            )
          else
            const Icon(Icons.location_off_rounded, color: _gold, size: 36),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(_statusMsg,
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(fontSize: 15, color: _textGold, height: 1.5),
            ),
          ),
          if (_hasError) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                setState(() { _hasError = false; _statusMsg = 'Retrying…'; });
                _initLocation();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                decoration: BoxDecoration(
                  color: _kiswahBlack,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Retry',
                    style: GoogleFonts.cormorantGaramond(
                        fontSize: 14, color: _gold, letterSpacing: 2)),
              ),
            ),
          ],
        ],
      ),
    ),
  );

  // ── Bottom info ───────────────────────────────────────────────────────────
  Widget _buildBottomInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Container(height: 1, color: _gold.withOpacity(0.5)),
          const SizedBox(height: 3),
          Container(height: 0.4, color: _gold.withOpacity(0.2)),
          const SizedBox(height: 16),
          if (_qiblaAngle != null)
            _isAligned ? _buildAlignedBadge() : _buildRotateHint(),
          const SizedBox(height: 12),
          _buildLocationChip(),
          const SizedBox(height: 16),
          Container(height: 0.4, color: _gold.withOpacity(0.2)),
          const SizedBox(height: 3),
          Container(height: 1, color: _gold.withOpacity(0.5)),
        ],
      ),
    );
  }

  Widget _buildAlignedBadge() => AnimatedBuilder(
    animation: _pulseCtrl,
    builder: (_, __) => Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      decoration: BoxDecoration(
        color: _kiswahBlack,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _gold, width: 1.2),
        boxShadow: [BoxShadow(
          color: _gold.withOpacity(0.2 * _pulseCtrl.value), blurRadius: 16,
        )],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.mosque_rounded, color: _gold, size: 18),
          const SizedBox(width: 8),
          Text('Facing the Qibla',
              style: GoogleFonts.cormorantGaramond(
                  fontSize: 17, fontWeight: FontWeight.w600,
                  color: _gold, letterSpacing: 1.5)),
        ],
      ),
    ),
  );

  Widget _buildRotateHint() {
    if (_qiblaAngle == null) return const SizedBox.shrink();
    final diff     = ((_qiblaAngle! - _deviceHeading) % 360 + 360) % 360;
    final turnLeft = diff > 180;
    final degrees  = turnLeft ? 360 - diff : diff;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: _kiswahBlack,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _gold.withOpacity(0.6), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(turnLeft ? Icons.rotate_left_rounded : Icons.rotate_right_rounded,
              color: _gold, size: 20),
          const SizedBox(width: 8),
          RichText(
            text: TextSpan(children: [
              TextSpan(text: 'Rotate ',
                  style: GoogleFonts.cormorantGaramond(fontSize: 15, color: _goldFaint)),
              TextSpan(text: '${degrees.toStringAsFixed(1)}°',
                  style: GoogleFonts.cormorantGaramond(
                      fontSize: 20, fontWeight: FontWeight.w700, color: _gold)),
              TextSpan(text: turnLeft ? ' left' : ' right',
                  style: GoogleFonts.cormorantGaramond(fontSize: 15, color: _goldFaint)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationChip() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _goldFaint, width: 1),
        boxShadow: [BoxShadow(color: _shadowGold, blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_rounded, color: _gold, size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              _qiblaAngle != null
                  ? '${_qiblaAngle!.toStringAsFixed(2)}° from North  •  $_statusMsg'
                  + (_locationSource.isNotEmpty ? '  via $_locationSource' : '')
                  : _statusMsg,
              style: GoogleFonts.cormorantGaramond(
                  fontSize: 13, color: _textGold, letterSpacing: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  // ── Kaaba illustration ────────────────────────────────────────────────────
  Widget _buildKaabaIllustration() {
    return Column(
      children: [
        Text('الكعبة المشرفة',
            style: GoogleFonts.amiri(fontSize: 16, color: _gold, letterSpacing: 2)),
        const SizedBox(height: 16),
        CustomPaint(
          size: const Size(120, 100),
          painter: _KaabaIllustrationPainter(),
        ),
      ],
    );
  }
}

// ─── Painters ─────────────────────────────────────────────────────────────────

class _KiswahDialPainter extends CustomPainter {
  final double shimmer;
  final bool isAligned;
  _KiswahDialPainter({required this.shimmer, required this.isAligned});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 4;

    canvas.drawCircle(c, r, Paint()..color = _kiswahBlack);

    canvas.drawCircle(c, r, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..shader = SweepGradient(
        transform: GradientRotation(shimmer * 2 * math.pi),
        colors: [_goldDeep, _gold, _goldPale, _gold, _goldDeep],
      ).createShader(Rect.fromCircle(center: c, radius: r)));

    canvas.drawCircle(c, r - 6,  Paint()..style = PaintingStyle.stroke..strokeWidth = 0.6..color = _gold.withOpacity(0.5));
    canvas.drawCircle(c, r - 11, Paint()..style = PaintingStyle.stroke..strokeWidth = 0.3..color = _gold.withOpacity(0.25));

    final tp = Paint()..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    for (int i = 0; i < 360; i++) {
      final a = _toRad(i.toDouble());
      final isMajor = i % 90 == 0;
      final isMed   = i % 45 == 0;
      final isTen   = i % 10 == 0;
      double ir, or2;
      if (isMajor)    { ir = r-26; or2 = r-6; tp..color=_gold..strokeWidth=2.2; }
      else if (isMed) { ir = r-18; or2 = r-6; tp..color=_gold.withOpacity(0.7)..strokeWidth=1.4; }
      else if (isTen) { ir = r-12; or2 = r-6; tp..color=_gold.withOpacity(0.45)..strokeWidth=0.8; }
      else            { ir = r-8;  or2 = r-6; tp..color=_gold.withOpacity(0.2)..strokeWidth=0.5; }

      canvas.drawLine(
        Offset(c.dx + ir  * math.sin(a), c.dy - ir  * math.cos(a)),
        Offset(c.dx + or2 * math.sin(a), c.dy - or2 * math.cos(a)),
        tp,
      );
    }

    canvas.drawCircle(c, 58, Paint()..color = _kiswahBlack2);
    canvas.drawCircle(c, 58, Paint()..style=PaintingStyle.stroke..strokeWidth=1.0..color=_gold.withOpacity(0.6));
    canvas.drawCircle(c, 50, Paint()..style=PaintingStyle.stroke..strokeWidth=0.4..color=_gold.withOpacity(0.25));
  }

  @override
  bool shouldRepaint(_KiswahDialPainter o) => o.shimmer != shimmer || o.isAligned != isAligned;
}

class _KiswahNeedlePainter extends CustomPainter {
  final double pulse;
  final bool isAligned;
  _KiswahNeedlePainter({required this.pulse, required this.isAligned});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);

    if (isAligned) {
      canvas.drawCircle(Offset(c.dx, c.dy - 86), 16, Paint()
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12 + 8 * pulse)
        ..color = _gold.withOpacity(0.45 + 0.3 * pulse));
    }

    final path = Path()
      ..moveTo(c.dx, c.dy - 104)
      ..lineTo(c.dx - 7, c.dy - 22)
      ..lineTo(c.dx, c.dy - 12)
      ..lineTo(c.dx + 7, c.dy - 22)
      ..close();

    canvas.drawPath(path, Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: isAligned ? [_goldPale, _gold] : [_gold, _goldDeep],
      ).createShader(Rect.fromPoints(Offset(c.dx, c.dy - 104), c)));
    canvas.drawPath(path, Paint()..style=PaintingStyle.stroke..strokeWidth=0.8..color=_goldDeep);

    // Kaaba cube at tip
    final cubeRect = Rect.fromCenter(center: Offset(c.dx, c.dy - 113), width: 18, height: 16);
    canvas.drawRRect(RRect.fromRectAndRadius(cubeRect, const Radius.circular(2)),
        Paint()..color = _kiswahBlack);
    canvas.drawRRect(RRect.fromRectAndRadius(cubeRect, const Radius.circular(2)),
        Paint()..style=PaintingStyle.stroke..strokeWidth=1.6..color=_gold);
    final bandY = cubeRect.top + 5;
    canvas.drawLine(Offset(cubeRect.left, bandY), Offset(cubeRect.right, bandY),
        Paint()..color=_gold..strokeWidth=1.0);
    canvas.drawLine(Offset(cubeRect.left, bandY+3.5), Offset(cubeRect.right, bandY+3.5),
        Paint()..color=_gold..strokeWidth=1.0);
    final door = Rect.fromCenter(center: Offset(c.dx, cubeRect.bottom - 4), width: 6, height: 7);
    canvas.drawRRect(RRect.fromRectAndRadius(door, const Radius.circular(0.5)),
        Paint()..color=_gold.withOpacity(0.9));

    // Counter needle
    final back = Path()
      ..moveTo(c.dx, c.dy + 56)
      ..lineTo(c.dx - 5, c.dy + 18)
      ..lineTo(c.dx, c.dy + 10)
      ..lineTo(c.dx + 5, c.dy + 18)
      ..close();
    canvas.drawPath(back, Paint()..color=_kiswahBlack2.withOpacity(0.5));
  }

  @override
  bool shouldRepaint(_KiswahNeedlePainter o) => o.pulse != pulse || o.isAligned != isAligned;
}

class _GoldRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: size.width / 2 - 2),
      0, 3 * math.pi / 2, false,
      Paint()
        ..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round
        ..shader = SweepGradient(colors: [Colors.transparent, _gold])
            .createShader(Rect.fromCircle(center: c, radius: size.width / 2)),
    );
  }
  @override bool shouldRepaint(_) => true;
}

class _KaabaIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final body = Rect.fromLTWH(w*0.1, h*0.1, w*0.8, h*0.82);
    canvas.drawRRect(RRect.fromRectAndRadius(body, const Radius.circular(2)),
        Paint()..color=_kiswahBlack);
    canvas.drawRRect(RRect.fromRectAndRadius(body, const Radius.circular(2)),
        Paint()..style=PaintingStyle.stroke..strokeWidth=1.8..color=_gold);

    final bandTop = h * 0.28;
    canvas.drawRect(Rect.fromLTWH(w*0.1, bandTop, w*0.8, h*0.14),
        Paint()..color=_gold.withOpacity(0.2));
    canvas.drawLine(Offset(w*0.1, bandTop), Offset(w*0.9, bandTop),
        Paint()..color=_gold..strokeWidth=1.2);
    canvas.drawLine(Offset(w*0.1, bandTop+h*0.14), Offset(w*0.9, bandTop+h*0.14),
        Paint()..color=_gold..strokeWidth=1.2);

    final door = Rect.fromLTWH(w*0.36, h*0.5, w*0.28, h*0.42);
    canvas.drawRRect(RRect.fromRectAndRadius(door, const Radius.circular(2)),
        Paint()..color=_gold);
    canvas.drawLine(Offset(w*0.5, door.top+4), Offset(w*0.5, door.bottom-4),
        Paint()..color=_kiswahBlack..strokeWidth=0.8);

    canvas.drawOval(Rect.fromCenter(center: Offset(w*0.1, h*0.18), width: 12, height: 9),
        Paint()..color=const Color(0xFF2A1A00));
    canvas.drawOval(Rect.fromCenter(center: Offset(w*0.1, h*0.18), width: 12, height: 9),
        Paint()..style=PaintingStyle.stroke..strokeWidth=1..color=_gold);
    canvas.drawOval(Rect.fromCenter(center: Offset(w*0.1, h*0.18), width: 5, height: 4),
        Paint()..color=_gold.withOpacity(0.5));
  }
  @override bool shouldRepaint(_) => false;
}