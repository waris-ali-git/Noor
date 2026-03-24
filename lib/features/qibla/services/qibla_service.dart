import 'dart:math' show sin, cos, atan2, pi;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';

class QiblaService {
  static const double _meccaLat = 21.422487;
  static const double _meccaLon = 39.826206;

  // Converts degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  // Converts radians to degrees
  double _radiansToDegrees(double radians) {
    return radians * 180.0 / pi;
  }

  /// Calculates the Qibla bearing from true north using spherical trigonometry
  double calculateQiblaDirection(double latitude, double longitude) {
    final lat1 = _degreesToRadians(latitude);
    final lon1 = _degreesToRadians(longitude);
    final lat2 = _degreesToRadians(_meccaLat);
    final lon2 = _degreesToRadians(_meccaLon);

    final dLon = lon2 - lon1;

    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    final bearing = atan2(y, x);
    final degrees = _radiansToDegrees(bearing);

    // Normalize to 0..360
    return (degrees + 360) % 360;
  }

  /// Request location permissions and get current coordinates
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
  }

  /// Stream of compass events (heading angle from true north)
  Stream<CompassEvent>? get compassStream => FlutterCompass.events;
}
