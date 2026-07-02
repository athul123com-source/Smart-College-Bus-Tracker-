import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/bus_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/location_service.dart';
import '../../models/bus_model.dart';
import '../../theme/app_theme.dart';
import '../../services/speed_calculation_service.dart';
import '../../services/detour_detection_service.dart';
import '../../services/notification_service.dart';
import '../auth/login_screen.dart';
import 'route_config_screen.dart';
import 'route_change_screen.dart';
import 'dart:async';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  GoogleMapController? _mapController;
  LocationService? _locationService;
  SpeedCalculationService? _speedService;
  DetourDetectionService? _detourService;
  bool _isTripActive = false;
  Position? _currentPosition;
  double _currentSpeed = 0;
  bool _detourDetected = false;
  bool _mapLoadFailed = false;
  bool _mapTilesLoaded = false;
  Timer? _mapInitTimer;

  @override
  void dispose() {
    _mapInitTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _locationService = Provider.of<LocationService>(context, listen: false);
    _speedService = SpeedCalculationService();
    _detourService = DetourDetectionService();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      final position = await _locationService!.getCurrentLocation();
      setState(() => _currentPosition = position);
      if (_mapController != null && position != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location error: $e')),
        );
      }
    }
  }

  void _startMapInitTimeout() {
    if (_mapInitTimer?.isActive ?? false) {
      return;
    }

    _mapInitTimer = Timer(const Duration(seconds: 10), () {
      if (!_mapTilesLoaded && mounted) {
        setState(() => _mapLoadFailed = true);
      }
    });
  }

  Future<void> _toggleTrip() async {
    final busProvider = Provider.of<BusProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Prefer driver's assigned bus; otherwise fall back to the sample bus_001 used in Firestore.
    final busId = authProvider.currentUser?.busId ?? 'bus_001';

    if (!_isTripActive) {
      // Start trip
      await busProvider.updateBusStatus(busId: busId, isActive: true);
      _startLocationUpdates(busId);
    } else {
      // Stop trip
      await busProvider.updateBusStatus(busId: busId, isActive: false);
    }

    setState(() => _isTripActive = !_isTripActive);
  }

  void _startLocationUpdates(String busId) async {
    final busProvider = Provider.of<BusProvider>(context, listen: false);
    BusModel? bus;

    // Get bus data
    try {
      bus = await busProvider.getBusStream(busId).first;
    } catch (e) {
      // Ignore and fall back to default bus below.
    }

    // `getBusStream(...).first` returns `BusModel?`, so ensure we always have a non-null model.
    final BusModel busData = bus ??
        BusModel(
          id: busId,
          busNumber: 'BUS-001',
          routeName: 'Main Route',
          stops: const [],
        );

    _locationService!.getLocationStream().listen((position) async {
      // Calculate speed using enhanced service
      final speed = _speedService!.addPositionAndCalculateSpeed(
        latitude: position.latitude,
        longitude: position.longitude,
        gpsSpeed: position.speed * 3.6, // Convert m/s to km/h
      );

      setState(() {
        _currentSpeed = speed;
      });

      // Update bus location
      await busProvider.updateBusLocation(
        busId: busId,
        latitude: position.latitude,
        longitude: position.longitude,
        speed: speed,
      );

      // Check for detour
      if (busData.stops.isNotEmpty) {
        final isDetour = await _detourService!.checkAndNotifyDetour(
          bus: busData,
          currentLat: position.latitude,
          currentLon: position.longitude,
        );

        if (isDetour && !_detourDetected) {
          setState(() => _detourDetected = true);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('Detour detected! Notification sent to all users.'),
                backgroundColor: AppTheme.warningColor,
              ),
            );
          }
        }
      }

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final busProvider = Provider.of<BusProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
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
                        Text(
                          'Trip Status',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isTripActive ? 'Active' : 'Inactive',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: _isTripActive
                                        ? AppTheme.successColor
                                        : AppTheme.textSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _toggleTrip,
                      icon: Icon(_isTripActive ? Icons.stop : Icons.play_arrow),
                      label: Text(_isTripActive ? 'Stop Trip' : 'Start Trip'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isTripActive
                            ? AppTheme.errorColor
                            : AppTheme.successColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                if (_isTripActive) ...[
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSpeedInfo('Current Speed',
                          '${_currentSpeed.toStringAsFixed(1)} km/h'),
                      if (_detourDetected)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning,
                                  size: 16, color: AppTheme.warningColor),
                              const SizedBox(width: 4),
                              Text(
                                'Detour',
                                style: TextStyle(
                                  color: AppTheme.warningColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Map View
          Expanded(
            flex: 2,
            child: _currentPosition == null
                ? const Center(child: CircularProgressIndicator())
                : (() {
                    // Detect maps that never finish tile loading (e.g., invalid/restricted API key).
                    _startMapInitTimeout();

                    return Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            ),
                            zoom: 15,
                          ),
                          onMapCreated: (controller) {
                            _mapController = controller;
                            setState(() => _mapLoadFailed = false);
                          },
                          onCameraIdle: () {
                            _mapTilesLoaded = true;
                            _mapInitTimer?.cancel();
                            setState(() => _mapLoadFailed = false);
                          },
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          markers: _isTripActive && _currentPosition != null
                              ? {
                                  Marker(
                                    markerId:
                                        const MarkerId('current_location'),
                                    position: LatLng(
                                      _currentPosition!.latitude,
                                      _currentPosition!.longitude,
                                    ),
                                    icon: BitmapDescriptor.defaultMarkerWithHue(
                                      BitmapDescriptor.hueBlue,
                                    ),
                                  ),
                                }
                              : {},
                        ),
                        if (_mapLoadFailed)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.6),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.map_outlined,
                                      size: 64, color: Colors.white),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Map failed to initialize.',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'This usually means the Google Maps API key is missing or invalid for your platform.\n\nFollow the setup guide to add a valid API key to Android and iOS, then restart the app.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.white70),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  })(),
          ),
          // Quick Actions
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.route,
                  label: 'Configure Route',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RouteConfigScreen(),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  icon: Icons.change_circle,
                  label: 'Change Route',
                  onTap: () {
                    final bus = busProvider.selectedBus ??
                        BusModel(
                          id: 'bus_001',
                          busNumber: 'BUS-001',
                          routeName: 'Main Campus Route',
                          stops: const [],
                        );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RouteChangeScreen(bus: bus),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  icon: Icons.info_outline,
                  label: 'Bus Info',
                  onTap: () {
                    _showBusInfo(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
        ),
      ],
    );
  }

  void _showBusInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bus Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bus Number: BUS-001'),
            const Text('Route: Main Campus Route'),
            if (_isTripActive) ...[
              const SizedBox(height: 8),
              Text('Current Speed: ${_currentSpeed.toStringAsFixed(1)} km/h'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
