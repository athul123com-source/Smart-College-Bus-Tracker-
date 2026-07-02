import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bus_model.dart';
import '../services/location_service.dart';

class BusProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocationService _locationService = LocationService();

  List<BusModel> _buses = [];
  BusModel? _selectedBus;
  bool _isLoading = false;
  String? _errorMessage;

  List<BusModel> get buses => _buses;
  BusModel? get selectedBus => _selectedBus;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAllBuses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('buses').get();
      _buses = snapshot.docs
          .map((doc) => BusModel.fromMap({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<BusModel>> getBusesStream() {
    return _firestore.collection('buses').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => BusModel.fromMap({
                'id': doc.id,
                ...doc.data(),
              }))
          .toList();
    });
  }

  Stream<BusModel?> getBusStream(String busId) {
    return _firestore
        .collection('buses')
        .doc(busId)
        .snapshots()
        .map((doc) => doc.exists
            ? BusModel.fromMap({
                'id': doc.id,
                ...doc.data()!,
              })
            : null);
  }

  void selectBus(BusModel bus) {
    _selectedBus = bus;
    notifyListeners();
  }

  Future<void> updateBusLocation({
    required String busId,
    required double latitude,
    required double longitude,
    required double speed,
  }) async {
    try {
      await _firestore.collection('buses').doc(busId).update({
        'currentLatitude': latitude,
        'currentLongitude': longitude,
        'currentSpeed': speed,
        'lastUpdateTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateBusStatus({
    required String busId,
    required bool isActive,
  }) async {
    try {
      await _firestore.collection('buses').doc(busId).update({
        'isActive': isActive,
      });
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> createRoute({
    required String busId,
    required List<BusStop> stops,
  }) async {
    try {
      await _firestore.collection('buses').doc(busId).update({
        'stops': stops.map((stop) => stop.toMap()).toList(),
      });
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<String?> calculateETA({
    required double busLat,
    required double busLon,
    required double stopLat,
    required double stopLon,
    required double speed,
  }) async {
    try {
      final distance = _locationService.calculateDistance(
        busLat,
        busLon,
        stopLat,
        stopLon,
      );
      final etaMinutes = _locationService.calculateETA(distance, speed);
      return etaMinutes.toStringAsFixed(0);
    } catch (e) {
      return null;
    }
  }
}




