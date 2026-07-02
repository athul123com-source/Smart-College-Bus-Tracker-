import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../models/bus_model.dart';

class SpeedCalculationService {
  final LocationService _locationService = LocationService();
  
  // Store recent position history for speed calculation
  final List<SpeedDataPoint> _positionHistory = [];
  static const int maxHistorySize = 10;

  /// Calculate current speed from GPS data
  double calculateCurrentSpeed(Position position) {
    // GPS provides speed directly in m/s, convert to km/h
    return position.speed * 3.6;
  }

  /// Calculate speed based on distance traveled
  double calculateSpeedFromDistance({
    required double previousLat,
    required double previousLon,
    required double currentLat,
    required double currentLon,
    required Duration timeElapsed,
  }) {
    if (timeElapsed.inSeconds == 0) return 0;

    final distanceKm = _locationService.calculateDistance(
      previousLat,
      previousLon,
      currentLat,
      currentLon,
    );

    return _locationService.calculateSpeed(
      distanceKm: distanceKm,
      timeElapsed: timeElapsed,
    );
  }

  /// Get average speed over recent positions
  double getAverageSpeed() {
    if (_positionHistory.length < 2) return 0;
    return _locationService.calculateAverageSpeed(_positionHistory);
  }

  /// Add position to history and calculate speed
  double addPositionAndCalculateSpeed({
    required double latitude,
    required double longitude,
    required double? gpsSpeed, // Speed from GPS if available
  }) {
    final now = DateTime.now();
    
    // Add to history
    final speedDataPoint = SpeedDataPoint(
      speed: gpsSpeed ?? 0,
      timestamp: now,
      latitude: latitude,
      longitude: longitude,
    );
    
    _positionHistory.add(speedDataPoint);
    
    // Keep history size manageable
    if (_positionHistory.length > maxHistorySize) {
      _positionHistory.removeAt(0);
    }

    // Calculate speed from distance if GPS speed not available
    if (gpsSpeed == null || gpsSpeed == 0) {
      if (_positionHistory.length >= 2) {
        final previous = _positionHistory[_positionHistory.length - 2];
        final timeElapsed = now.difference(previous.timestamp);
        
        if (timeElapsed.inSeconds > 0) {
          return calculateSpeedFromDistance(
            previousLat: previous.latitude,
            previousLon: previous.longitude,
            currentLat: latitude,
            currentLon: longitude,
            timeElapsed: timeElapsed,
          );
        }
      }
      return 0;
    }

    return gpsSpeed;
  }

  /// Clear position history
  void clearHistory() {
    _positionHistory.clear();
  }

  /// Get speed statistics
  Map<String, double> getSpeedStatistics() {
    if (_positionHistory.isEmpty) {
      return {
        'current': 0,
        'average': 0,
        'max': 0,
        'min': 0,
      };
    }

    final speeds = _positionHistory
        .where((p) => p.speed > 0)
        .map((p) => p.speed)
        .toList();

    if (speeds.isEmpty) {
      return {
        'current': 0,
        'average': 0,
        'max': 0,
        'min': 0,
      };
    }

    return {
      'current': _positionHistory.last.speed,
      'average': speeds.reduce((a, b) => a + b) / speeds.length,
      'max': speeds.reduce((a, b) => a > b ? a : b),
      'min': speeds.reduce((a, b) => a < b ? a : b),
    };
  }
}

