import 'package:geolocator/geolocator.dart';
import '../models/bus_model.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }

  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // in km
  }

  double calculateETA(double distanceKm, double speedKmh) {
    if (speedKmh <= 0) return 0;
    return (distanceKm / speedKmh) * 60; // in minutes
  }

  /// Calculate speed based on distance and time
  double calculateSpeed({
    required double distanceKm,
    required Duration timeElapsed,
  }) {
    if (timeElapsed.inSeconds == 0) return 0;
    final hours = timeElapsed.inSeconds / 3600;
    return distanceKm / hours; // km/h
  }

  /// Calculate average speed from multiple positions
  double calculateAverageSpeed(List<SpeedDataPoint> dataPoints) {
    if (dataPoints.isEmpty) return 0;
    
    double totalSpeed = 0;
    int validPoints = 0;
    
    for (var point in dataPoints) {
      if (point.speed > 0) {
        totalSpeed += point.speed;
        validPoints++;
      }
    }
    
    return validPoints > 0 ? totalSpeed / validPoints : 0;
  }

  /// Detect if bus is deviating from route (detour detection)
  bool isDetourDetected({
    required double currentLat,
    required double currentLon,
    required List<BusStop> routeStops,
    required double maxDeviationKm, // Maximum allowed deviation in km
  }) {
    if (routeStops.isEmpty) return false;

    // Find nearest point on route
    double minDistance = double.infinity;
    
    for (var stop in routeStops) {
      final distance = calculateDistance(
        currentLat,
        currentLon,
        stop.latitude,
        stop.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
      }
    }

    // Check if current position is too far from any route point
    return minDistance > maxDeviationKm;
  }
}

class SpeedDataPoint {
  final double speed; // km/h
  final DateTime timestamp;
  final double latitude;
  final double longitude;

  SpeedDataPoint({
    required this.speed,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
  });
}


