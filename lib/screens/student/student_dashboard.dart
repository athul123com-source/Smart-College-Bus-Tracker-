import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/bus_provider.dart';
import 'dart:async';
import '../../providers/auth_provider.dart';
import '../../models/bus_model.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import 'bus_selection_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  GoogleMapController? _mapController;
  bool _mapLoadFailed = false;
  bool _mapTilesLoaded = false;
  Timer? _mapInitTimer;

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

  @override
  void dispose() {
    _mapInitTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final busProvider = Provider.of<BusProvider>(context, listen: false);
    busProvider.fetchAllBuses();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final busProvider = Provider.of<BusProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Tracker'),
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
          // Bus Selection Card
          if (busProvider.selectedBus == null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.warningColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No Bus Selected',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Select a bus to track',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BusSelectionScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.warningColor,
                    ),
                    child: const Text('Select Bus'),
                  ),
                ],
              ),
            )
          else
            StreamBuilder<BusModel?>(
              stream: busProvider.getBusStream(busProvider.selectedBus!.id),
              builder: (context, snapshot) {
                final bus = snapshot.data ?? busProvider.selectedBus;
                if (bus == null) {
                  return const SizedBox.shrink();
                }

                return _buildBusInfoCard(context, bus);
              },
            ),
          // Map View
          Expanded(
            child: busProvider.selectedBus == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Select a bus to view on map',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                        ),
                      ],
                    ),
                  )
                : StreamBuilder<BusModel?>(
                    stream:
                        busProvider.getBusStream(busProvider.selectedBus!.id),
                    builder: (context, snapshot) {
                      final bus = snapshot.data ?? busProvider.selectedBus;
                      if (bus == null || bus.currentLatitude == null) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // Detect maps that never finish tile loading (e.g., invalid/restricted API key).
                      _startMapInitTimeout();

                      return Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                bus.currentLatitude!,
                                bus.currentLongitude!,
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
                            markers: {
                              Marker(
                                markerId: MarkerId(bus.id),
                                position: LatLng(
                                  bus.currentLatitude!,
                                  bus.currentLongitude!,
                                ),
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueBlue,
                                ),
                                infoWindow: InfoWindow(
                                  title: bus.busNumber,
                                  snippet: bus.routeName,
                                ),
                              ),
                              ...bus.stops.map((stop) => Marker(
                                    markerId: MarkerId(stop.id),
                                    position:
                                        LatLng(stop.latitude, stop.longitude),
                                    icon: BitmapDescriptor.defaultMarkerWithHue(
                                      BitmapDescriptor.hueGreen,
                                    ),
                                    infoWindow: InfoWindow(title: stop.name),
                                  )),
                            },
                            polylines: {
                              Polyline(
                                polylineId: PolylineId(bus.id),
                                points: bus.stops
                                    .map((stop) =>
                                        LatLng(stop.latitude, stop.longitude))
                                    .toList(),
                                color: AppTheme.primaryColor,
                                width: 3,
                              ),
                            },
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
                    },
                  ),
          ),
          // ETA and Next Stop Info
          if (busProvider.selectedBus != null)
            StreamBuilder<BusModel?>(
              stream: busProvider.getBusStream(busProvider.selectedBus!.id),
              builder: (context, snapshot) {
                final bus = snapshot.data ?? busProvider.selectedBus;
                if (bus == null) return const SizedBox.shrink();

                return _buildETAInfo(context, bus);
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const BusSelectionScreen(),
            ),
          );
        },
        icon: const Icon(Icons.directions_bus),
        label:
            Text(busProvider.selectedBus == null ? 'Select Bus' : 'Change Bus'),
      ),
    );
  }

  Widget _buildBusInfoCard(BuildContext context, BusModel bus) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bus.busNumber,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bus.routeName,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: bus.isActive
                      ? AppTheme.successColor.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            bus.isActive ? AppTheme.successColor : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      bus.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color:
                            bus.isActive ? AppTheme.successColor : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (bus.driverName != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person,
                    size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'Driver: ${bus.driverName}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildETAInfo(BuildContext context, BusModel bus) {
    if (bus.currentLatitude == null || bus.stops.isEmpty) {
      return const SizedBox.shrink();
    }

    // Find next stop (simplified - in real app, calculate based on current position)
    final nextStop = bus.stops.isNotEmpty ? bus.stops[0] : null;
    if (nextStop == null) return const SizedBox.shrink();

    final busProvider = Provider.of<BusProvider>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next Stop',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  nextStop.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<String?>(
            future: busProvider.calculateETA(
              busLat: bus.currentLatitude!,
              busLon: bus.currentLongitude!,
              stopLat: nextStop.latitude,
              stopLon: nextStop.longitude,
              speed: bus.currentSpeed ?? 30,
            ),
            builder: (context, snapshot) {
              final etaMinutes = snapshot.data ?? 'N/A';
              return Row(
                children: [
                  const Icon(Icons.access_time, color: AppTheme.warningColor),
                  const SizedBox(width: 8),
                  Text(
                    'ETA: $etaMinutes minutes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.warningColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
