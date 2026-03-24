import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import '../../../core/di.dart';
import '../../../core/widgets/translated_text.dart';
import '../services/qibla_service.dart';

class QiblaHomeScreen extends StatefulWidget {
  const QiblaHomeScreen({super.key});

  @override
  State<QiblaHomeScreen> createState() => _QiblaHomeScreenState();
}

class _QiblaHomeScreenState extends State<QiblaHomeScreen> with SingleTickerProviderStateMixin {
  final QiblaService _qiblaService = sl<QiblaService>();
  
  bool _isLoading = true;
  String? _errorMessage;
  double? _qiblaDirection; // Bearing from North to Kaaba
  Position? _location;

  // For smooth rotation without 360 jump
  double _lastHeading = 0;
  double _cumulativeHeading = 0;
  
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _initQibla();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initQibla() async {
    try {
      final position = await _qiblaService.getCurrentLocation();
      if (position == null) {
        setState(() {
          _errorMessage = "Please enable Location Services and grant permissions to find Qibla.";
          _isLoading = false;
        });
        return;
      }

      final qiblaDir = _qiblaService.calculateQiblaDirection(
          position.latitude, position.longitude);

      setState(() {
        _location = position;
        _qiblaDirection = qiblaDir;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Failed to get location: $e";
        _isLoading = false;
      });
    }
  }

  // Prevents the needle from spinning completely around when crossing North (359 -> 0)
  double _calculateSmoothHeading(double newHeading) {
    double diff = newHeading - _lastHeading;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    _cumulativeHeading += diff;
    _lastHeading = newHeading;
    return _cumulativeHeading;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: const TranslatedText('Qibla Compass', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              TranslatedText(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() => _isLoading = true);
                  _initQibla();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const TranslatedText('Retry', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }

    return StreamBuilder<CompassEvent>(
      stream: _qiblaService.compassStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error reading compass: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data?.heading == null) {
          return const Center(
            child: TranslatedText(
              'Device does not have a compass sensor.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        final heading = snapshot.data!.heading!;
        final smoothHeading = _calculateSmoothHeading(heading);
        
        // The rotation angle required to point NORTH upwards
        final northRotation = -smoothHeading * pi / 180;
        
        // The rotation angle to point exactly at Qibla
        final qiblaRotation = (_qiblaDirection! - smoothHeading) * pi / 180;

        // Is user facing Qibla? (Within 5 degrees)
        final diffFromQibla = (heading - _qiblaDirection!).abs() % 360;
        final isFacingQibla = diffFromQibla < 5 || diffFromQibla > 355;

        return Column(
          children: [
            const Spacer(),
            // Title and accuracy status
            TranslatedText(
              isFacingQibla ? "You are facing the Qibla" : "Rotate to find Qibla",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isFacingQibla ? Colors.teal : Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
               "${_qiblaDirection?.toStringAsFixed(1)}°",
               style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            
            // The Compass
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Beautiful Outer Dial with shadow
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: isFacingQibla ? Colors.teal.withValues(alpha: 0.3) : Colors.black12,
                          blurRadius: isFacingQibla ? 30 : 15,
                          spreadRadius: isFacingQibla ? 10 : 2,
                        ),
                      ],
                    ),
                  ),

                  // North Pointer (Rotates relative to device)
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: northRotation, end: northRotation),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutQuart,
                    builder: (context, angle, child) {
                      return Transform.rotate(
                        angle: angle,
                        child: child,
                      );
                    },
                    child: _buildCompassDial(),
                  ),

                  // Qibla Pointer
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: qiblaRotation, end: qiblaRotation),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutQuart,
                    builder: (context, angle, child) {
                      return Transform.rotate(
                        angle: angle,
                        child: child,
                      );
                    },
                    child: _buildQiblaNeedle(isFacingQibla),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
            
            // Location info
            if (_location != null) ...[
               const Icon(Icons.location_on, color: Colors.grey, size: 20),
               const SizedBox(height: 4),
               Text(
                 "Lat: ${_location!.latitude.toStringAsFixed(4)}, Lng: ${_location!.longitude.toStringAsFixed(4)}",
                 style: const TextStyle(color: Colors.grey),
               ),
            ],
            const SizedBox(height: 48),
          ],
        );
      },
    );
  }

  Widget _buildCompassDial() {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Basic cardinal points
          Positioned(top: 10, child: _compassText("N", Colors.red)),
          Positioned(bottom: 10, child: _compassText("S", Colors.black54)),
          Positioned(right: 15, child: _compassText("E", Colors.black54)),
          Positioned(left: 15, child: _compassText("W", Colors.black54)),
          
          // Minor ticks
          for (int i = 0; i < 360; i += 15)
            Transform.rotate(
              angle: i * pi / 180,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 35),
                  width: i % 90 == 0 ? 3 : 1.5,
                  height: i % 90 == 0 ? 15 : 8,
                  color: i == 0 ? Colors.red : Colors.grey.shade400,
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildQiblaNeedle(bool isFacingQibla) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center dot
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: isFacingQibla ? Colors.teal : Colors.blueGrey,
              shape: BoxShape.circle,
            ),
          ),
          // Main needle
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                const SizedBox(height: 45), // Push down from edge
                // Kaaba Icon or solid marker
                Icon(
                  Icons.location_on,
                  color: isFacingQibla ? Colors.teal : Colors.amber.shade700,
                  size: 40,
                ),
                Container(
                  width: 4,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isFacingQibla ? Colors.teal : Colors.amber.shade700,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _compassText(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }
}
