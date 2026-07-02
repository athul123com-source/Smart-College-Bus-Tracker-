class BusModel {
  final String id;
  final String busNumber;
  final String routeName;
  final String? driverId;
  final String? driverName;
  final bool isActive;
  final List<BusStop> stops;
  final double? currentLatitude;
  final double? currentLongitude;
  final double? currentSpeed; // in km/h
  final DateTime? lastUpdateTime;

  BusModel({
    required this.id,
    required this.busNumber,
    required this.routeName,
    this.driverId,
    this.driverName,
    this.isActive = false,
    required this.stops,
    this.currentLatitude,
    this.currentLongitude,
    this.currentSpeed,
    this.lastUpdateTime,
  });

  factory BusModel.fromMap(Map<String, dynamic> map) {
    return BusModel(
      id: map['id'] ?? '',
      busNumber: map['busNumber'] ?? '',
      routeName: map['routeName'] ?? '',
      driverId: map['driverId'],
      driverName: map['driverName'],
      isActive: map['isActive'] ?? false,
      stops: (map['stops'] as List<dynamic>?)
              ?.map((stop) => BusStop.fromMap(stop as Map<String, dynamic>))
              .toList() ??
          [],
      currentLatitude: map['currentLatitude']?.toDouble(),
      currentLongitude: map['currentLongitude']?.toDouble(),
      currentSpeed: map['currentSpeed']?.toDouble(),
      lastUpdateTime: map['lastUpdateTime']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'busNumber': busNumber,
      'routeName': routeName,
      'driverId': driverId,
      'driverName': driverName,
      'isActive': isActive,
      'stops': stops.map((stop) => stop.toMap()).toList(),
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
      'currentSpeed': currentSpeed,
      'lastUpdateTime': lastUpdateTime,
    };
  }
}

class BusStop {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final int sequence;
  final String? arrivalTime;

  BusStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.sequence,
    this.arrivalTime,
  });

  factory BusStop.fromMap(Map<String, dynamic> map) {
    return BusStop(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      sequence: map['sequence'] ?? 0,
      arrivalTime: map['arrivalTime'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'sequence': sequence,
      'arrivalTime': arrivalTime,
    };
  }
}




