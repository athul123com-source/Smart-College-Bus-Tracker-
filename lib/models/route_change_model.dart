class RouteChangeModel {
  final String id;
  final String busId;
  final String busNumber;
  final String originalRoute;
  final String newRoute;
  final String reason;
  final DateTime effectiveTime;
  final DateTime notificationTime;
  final List<String> affectedStops;
  final List<String> newStops;
  final bool isActive;

  RouteChangeModel({
    required this.id,
    required this.busId,
    required this.busNumber,
    required this.originalRoute,
    required this.newRoute,
    required this.reason,
    required this.effectiveTime,
    required this.notificationTime,
    required this.affectedStops,
    required this.newStops,
    this.isActive = true,
  });

  factory RouteChangeModel.fromMap(Map<String, dynamic> map) {
    return RouteChangeModel(
      id: map['id'] ?? '',
      busId: map['busId'] ?? '',
      busNumber: map['busNumber'] ?? '',
      originalRoute: map['originalRoute'] ?? '',
      newRoute: map['newRoute'] ?? '',
      reason: map['reason'] ?? '',
      effectiveTime: map['effectiveTime']?.toDate() ?? DateTime.now(),
      notificationTime: map['notificationTime']?.toDate() ?? DateTime.now(),
      affectedStops: List<String>.from(map['affectedStops'] ?? []),
      newStops: List<String>.from(map['newStops'] ?? []),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'busId': busId,
      'busNumber': busNumber,
      'originalRoute': originalRoute,
      'newRoute': newRoute,
      'reason': reason,
      'effectiveTime': effectiveTime,
      'notificationTime': notificationTime,
      'affectedStops': affectedStops,
      'newStops': newStops,
      'isActive': isActive,
    };
  }
}



