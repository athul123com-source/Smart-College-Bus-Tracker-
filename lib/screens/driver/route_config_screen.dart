import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/bus_model.dart';
import '../../theme/app_theme.dart';

class RouteConfigScreen extends StatefulWidget {
  const RouteConfigScreen({super.key});

  @override
  State<RouteConfigScreen> createState() => _RouteConfigScreenState();
}

class _RouteConfigScreenState extends State<RouteConfigScreen> {
  final List<BusStop> _stops = [];
  final TextEditingController _stopNameController = TextEditingController();
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;

  @override
  void dispose() {
    _stopNameController.dispose();
    super.dispose();
  }

  void _addStop() {
    if (_selectedLocation == null || _stopNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location and enter stop name')),
      );
      return;
    }

    setState(() {
      _stops.add(BusStop(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _stopNameController.text,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        sequence: _stops.length + 1,
      ));
      _stopNameController.clear();
      _selectedLocation = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Route'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(11.0168, 76.9558), // Default location
                zoom: 13,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onTap: (LatLng location) {
                setState(() {
                  _selectedLocation = location;
                });
              },
              markers: {
                ..._stops.map((stop) => Marker(
                      markerId: MarkerId(stop.id),
                      position: LatLng(stop.latitude, stop.longitude),
                      infoWindow: InfoWindow(title: stop.name),
                    )),
                if (_selectedLocation != null)
                  Marker(
                    markerId: const MarkerId('selected'),
                    position: _selectedLocation!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
                  ),
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _stopNameController,
                  decoration: const InputDecoration(
                    labelText: 'Stop Name',
                    hintText: 'Enter bus stop name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _addStop,
                        child: const Text('Add Stop'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Save route
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                        ),
                        child: const Text('Save Route'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_stops.isNotEmpty)
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Route Stops (${_stops.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _stops.length,
                      itemBuilder: (context, index) {
                        final stop = _stops[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text('${stop.sequence}'),
                          ),
                          title: Text(stop.name),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _stops.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}




