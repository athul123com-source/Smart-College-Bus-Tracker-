import '../models/bus_model.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';

class DetourDetectionService {
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();
  
  // Maximum allowed deviation from route in kilometers
  static const double maxDeviationKm = 0.5; // 500 meters
  
  // Minimum time to confirm detour (in seconds)
  static const int detourConfirmationTime = 30;

  /// Check if bus is on detour and send notification if needed
  Future<bool> checkAndNotifyDetour({
    required BusModel bus,
    required double currentLat,
    required double currentLon,
    String? reason,
  }) async {
    if (bus.stops.isEmpty) return false;

    final isDetour = _locationService.isDetourDetected(
      currentLat: currentLat,
      currentLon: currentLon,
      routeStops: bus.stops,
      maxDeviationKm: maxDeviationKm,
    );

    if (isDetour) {
      // Send notification
      await _notificationService.notifyDetour(
        busId: bus.id,
        busNumber: bus.busNumber,
        reason: reason ?? 'Traffic or road conditions',
        deviationKm: _calculateDeviation(currentLat, currentLon, bus.stops),
      );
      return true;
    }

    return false;
  }

  /// Calculate deviation distance from route
  double _calculateDeviation(
    double currentLat,
    double currentLon,
    List<BusStop> stops,
  ) {
    if (stops.isEmpty) return 0;

    double minDistance = double.infinity;
    for (var stop in stops) {
      final distance = _locationService.calculateDistance(
        currentLat,
        currentLon,
        stop.latitude,
        stop.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
      }
    }
    return minDistance;
  }

  /// Monitor bus location continuously for detour detection
  Stream<bool> monitorDetour({
    required BusModel bus,
    required Stream<Map<String, double>> locationStream,
  }) async* {
    bool detourDetected = false;
    DateTime? detourStartTime;

    await for (var location in locationStream) {
      final currentLat = location['latitude']!;
      final currentLon = location['longitude']!;

      final isDetour = _locationService.isDetourDetected(
        currentLat: currentLat,
        currentLon: currentLon,
        routeStops: bus.stops,
        maxDeviationKm: maxDeviationKm,
      );

      if (isDetour && !detourDetected) {
        detourStartTime = DateTime.now();
        detourDetected = true;
        yield true;
      } else if (!isDetour && detourDetected) {
        // Bus returned to route
        detourDetected = false;
        detourStartTime = null;
        yield false;
      } else if (detourDetected &&
          detourStartTime != null &&
          DateTime.now().difference(detourStartTime!).inSeconds >
              detourConfirmationTime) {
        // Confirmed detour - send notification
        await _notificationService.notifyDetour(
          busId: bus.id,
          busNumber: bus.busNumber,
          reason: 'Route deviation detected',
          deviationKm: _calculateDeviation(currentLat, currentLon, bus.stops),
        );
        detourDetected = false; // Reset to avoid duplicate notifications
      }
    }
  }
}



